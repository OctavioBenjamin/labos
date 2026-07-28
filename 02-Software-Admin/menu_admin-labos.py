#!/usr/bin/env python3
"""Menú centralizado para administrar los laboratorios UNC."""

from __future__ import annotations

import curses
import locale
import shlex
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Sequence


SCRIPT_DIR = Path(__file__).resolve().parent
BASE_DIR = SCRIPT_DIR.parent

HOSTS = SCRIPT_DIR / "ansible" / "hosts.ini"
PLANTA_BAJA = "planta_baja"
PLANTA_ALTA = "planta_alta"

MACS_PA = "MACs_PA.txt"
MACS_PB = "MACs_PB.txt"

CONEXION_SCRIPT = "sudo /etc/psico/fw_conexion.sh"
PRENDER_AULA_SH = SCRIPT_DIR / "wake_aula-completa.sh"

TITLE = "Laboratorio UNC"
SUBTITLE = "Gestión centralizada"

PAIR_TITLE = 1
PAIR_ACCENT = 2
PAIR_SELECTED = 3
PAIR_MUTED = 4
PAIR_SUCCESS = 5
PAIR_WARNING = 6


@dataclass(frozen=True)
class MenuItem:
    code: str
    badge: str
    title: str
    detail: str


MAIN_OPTIONS = (
    MenuItem("firewall", "RED", "Firewall y Red", "Administrar el acceso a Internet"),
    MenuItem("energy", "ENERGÍA", "Energía", "Encender, apagar o reiniciar aulas"),
    MenuItem("admin", "ADMIN", "Administración", "Consultar el estado de los equipos"),
    MenuItem("exit", "SALIR", "Finalizar sesión", "Cerrar el menú de administración"),
)

FIREWALL_OPTIONS = (
    MenuItem("all_on", "TODO", "Activar Internet", "Todos los equipos"),
    MenuItem("all_off", "TODO", "Desactivar Internet", "Todos los equipos"),
    MenuItem("pb_on", "PB", "Activar Internet", "Planta baja"),
    MenuItem("pb_off", "PB", "Desactivar Internet", "Planta baja"),
    MenuItem("pa_on", "PA", "Activar Internet", "Planta alta"),
    MenuItem("pa_off", "PA", "Desactivar Internet", "Planta alta"),
    MenuItem("back", "VOLVER", "Menú principal", "Regresar a las categorías"),
)

ENERGY_OPTIONS = (
    MenuItem("all_wake", "TODO", "Encender aulas", "Todos los equipos"),
    MenuItem("all_shutdown", "TODO", "Apagar aulas", "Todos los equipos"),
    MenuItem("all_reboot", "TODO", "Reiniciar aulas", "Todos los equipos"),
    MenuItem("pb_wake", "PB", "Encender aula", "Planta baja"),
    MenuItem("pb_shutdown", "PB", "Apagar aula", "Planta baja"),
    MenuItem("pb_reboot", "PB", "Reiniciar aula", "Planta baja"),
    MenuItem("pa_wake", "PA", "Encender aula", "Planta alta"),
    MenuItem("pa_shutdown", "PA", "Apagar aula", "Planta alta"),
    MenuItem("pa_reboot", "PA", "Reiniciar aula", "Planta alta"),
    MenuItem("back", "VOLVER", "Menú principal", "Regresar a las categorías"),
)

ADMIN_OPTIONS = (
    MenuItem("ping", "PING", "Ver estado de equipos", "Ejecutar el módulo ping de Ansible"),
    MenuItem("back", "VOLVER", "Menú principal", "Regresar a las categorías"),
)


def init_screen(stdscr: "curses.window") -> None:
    stdscr.keypad(True)
    curses.noecho()
    curses.cbreak()
    try:
        curses.curs_set(0)
    except curses.error:
        pass

    if not curses.has_colors():
        return

    curses.start_color()
    try:
        curses.use_default_colors()
        background = -1
    except curses.error:
        background = curses.COLOR_BLACK

    curses.init_pair(PAIR_TITLE, curses.COLOR_CYAN, background)
    curses.init_pair(PAIR_ACCENT, curses.COLOR_BLUE, background)
    curses.init_pair(PAIR_SELECTED, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(PAIR_MUTED, curses.COLOR_WHITE, background)
    curses.init_pair(PAIR_SUCCESS, curses.COLOR_GREEN, background)
    curses.init_pair(PAIR_WARNING, curses.COLOR_YELLOW, background)


def add_text(
    window: "curses.window",
    y: int,
    x: int,
    text: str,
    attr: int = 0,
    width: Optional[int] = None,
) -> None:
    """Escribe texto sin fallar en terminales pequeñas."""
    height, window_width = window.getmaxyx()
    if y < 0 or y >= height or x < 0 or x >= window_width:
        return

    available = window_width - x - 1
    if width is not None:
        available = min(available, max(0, width))
    if available <= 0:
        return

    try:
        window.addnstr(y, x, text, available, attr)
    except curses.error:
        pass


def draw_rule(stdscr: "curses.window", y: int) -> None:
    _, width = stdscr.getmaxyx()
    if 0 < y:
        try:
            stdscr.hline(y, 1, curses.ACS_HLINE, max(0, width - 2))
        except curses.error:
            pass


def draw_too_small(stdscr: "curses.window") -> None:
    stdscr.erase()
    height, width = stdscr.getmaxyx()
    message = "Agrandá la terminal (mínimo: 64 x 16)"
    add_text(
        stdscr,
        max(0, height // 2),
        max(0, (width - len(message)) // 2),
        message,
        curses.color_pair(PAIR_WARNING) | curses.A_BOLD,
    )
    stdscr.refresh()


def draw_menu(
    stdscr: "curses.window",
    section: str,
    prompt: str,
    items: Sequence[MenuItem],
    selected: int,
    notice: str,
) -> None:
    stdscr.erase()
    height, width = stdscr.getmaxyx()
    stdscr.border()

    title = f" {TITLE} · {SUBTITLE} "
    add_text(
        stdscr,
        1,
        3,
        title,
        curses.color_pair(PAIR_TITLE) | curses.A_BOLD,
        width - 6,
    )
    draw_rule(stdscr, 2)

    add_text(
        stdscr,
        3,
        3,
        section.upper(),
        curses.color_pair(PAIR_ACCENT) | curses.A_BOLD,
        width - 6,
    )
    add_text(stdscr, 4, 3, prompt, curses.A_DIM, width - 6)

    first_row = 6
    footer_rule = height - 4
    visible_count = max(1, (footer_rule - first_row) // 2)
    page_start = min(
        max(0, selected - visible_count + 1),
        max(0, len(items) - visible_count),
    )
    visible_items = items[page_start : page_start + visible_count]

    content_width = max(1, width - 6)
    for visible_index, item in enumerate(visible_items):
        item_index = page_start + visible_index
        row = first_row + visible_index * 2
        is_selected = item_index == selected
        attr = curses.color_pair(PAIR_SELECTED) | curses.A_BOLD if is_selected else 0

        marker = "›" if is_selected else " "
        heading = f" {marker}  [{item.badge:<7}] {item.title}"
        detail = f"             {item.detail}"

        if is_selected:
            heading = heading.ljust(content_width)
            detail = detail.ljust(content_width)

        add_text(stdscr, row, 3, heading, attr, content_width)
        add_text(
            stdscr,
            row + 1,
            3,
            detail,
            attr if is_selected else curses.A_DIM,
            content_width,
        )

    draw_rule(stdscr, footer_rule)
    if len(items) > visible_count:
        position = f" {selected + 1}/{len(items)} "
        add_text(
            stdscr,
            footer_rule,
            max(2, width - len(position) - 3),
            position,
            curses.color_pair(PAIR_ACCENT) | curses.A_BOLD,
        )

    if notice:
        notice_pair = PAIR_WARNING if notice.startswith("Aviso") else PAIR_SUCCESS
        add_text(
            stdscr,
            height - 3,
            3,
            notice,
            curses.color_pair(notice_pair) | curses.A_BOLD,
            width - 6,
        )
    else:
        add_text(
            stdscr,
            height - 3,
            3,
            "Sistema listo",
            curses.color_pair(PAIR_SUCCESS),
            width - 6,
        )

    hints = "↑/↓ navegar   ENTER seleccionar   ESC/Q volver"
    add_text(stdscr, height - 2, 3, hints, curses.A_DIM, width - 6)
    stdscr.refresh()


def choose(
    stdscr: "curses.window",
    section: str,
    prompt: str,
    items: Sequence[MenuItem],
    notice: str = "",
) -> Optional[str]:
    selected = 0

    while True:
        height, width = stdscr.getmaxyx()
        if height < 16 or width < 64:
            draw_too_small(stdscr)
            key = stdscr.getch()
            if key in (27, ord("q"), ord("Q")):
                return None
            continue

        draw_menu(stdscr, section, prompt, items, selected, notice)
        key = stdscr.getch()

        if key in (curses.KEY_UP, ord("k"), ord("K")):
            selected = (selected - 1) % len(items)
        elif key in (curses.KEY_DOWN, ord("j"), ord("J")):
            selected = (selected + 1) % len(items)
        elif key in (curses.KEY_HOME,):
            selected = 0
        elif key in (curses.KEY_END,):
            selected = len(items) - 1
        elif key in (10, 13, curses.KEY_ENTER):
            return items[selected].code
        elif key in (27, ord("q"), ord("Q")):
            return None
        elif ord("1") <= key <= ord("9"):
            direct_index = key - ord("1")
            if direct_index < len(items):
                selected = direct_index
        elif key == curses.KEY_RESIZE:
            continue


def command_header(label: str, command: Sequence[str]) -> None:
    line = "═" * 68
    print(f"\033[1;36m{line}\033[0m")
    print(f"\033[1;36m  Laboratorio UNC\033[0m  ·  {label}")
    print(f"\033[1;36m{line}\033[0m")
    print(f"\033[2m$ {shlex.join(command)}\033[0m\n")


def run_command(
    stdscr: "curses.window", label: str, command: Sequence[str]
) -> int:
    """Pausa curses, ejecuta la herramienta original y restaura el menú."""
    curses.def_prog_mode()
    curses.endwin()
    result_code = 1

    try:
        command_header(label, command)
        result = subprocess.run(command, check=False)
        result_code = result.returncode
        if result_code == 0:
            print("\n\033[1;32m✓ Acción finalizada correctamente.\033[0m")
        else:
            print(f"\n\033[1;33m! La acción terminó con código {result_code}.\033[0m")
    except FileNotFoundError:
        print(f"\n\033[1;31m✗ No se encontró el comando: {command[0]}\033[0m")
        result_code = 127
    except KeyboardInterrupt:
        print("\n\033[1;33m! Acción interrumpida por el usuario.\033[0m")
        result_code = 130
    except OSError as error:
        print(f"\n\033[1;31m✗ No se pudo ejecutar la acción: {error}\033[0m")
        result_code = 1
    finally:
        try:
            input("\nPresione ENTER para volver al menú...")
        except EOFError:
            pass
        curses.reset_prog_mode()
        stdscr.refresh()
        try:
            curses.curs_set(0)
        except curses.error:
            pass
        curses.flushinp()

    return result_code


def result_notice(result_code: int) -> str:
    if result_code == 0:
        return "Acción finalizada correctamente"
    return f"Aviso: la acción terminó con código {result_code}"


def menu_firewall(stdscr: "curses.window") -> None:
    actions = {
        "all_on": ("all", "on", "Activar Internet · Todos"),
        "all_off": ("all", "off", "Desactivar Internet · Todos"),
        "pb_on": (PLANTA_BAJA, "on", "Activar Internet · Planta baja"),
        "pb_off": (PLANTA_BAJA, "off", "Desactivar Internet · Planta baja"),
        "pa_on": (PLANTA_ALTA, "on", "Activar Internet · Planta alta"),
        "pa_off": (PLANTA_ALTA, "off", "Desactivar Internet · Planta alta"),
    }
    notice = ""

    while True:
        choice = choose(
            stdscr,
            "Firewall y Red",
            "Elegí el alcance y el estado de conectividad",
            FIREWALL_OPTIONS,
            notice,
        )
        if choice in (None, "back"):
            return

        group, action, label = actions[choice]
        command = [
            "ansible",
            group,
            "-i",
            str(HOSTS),
            "-m",
            "shell",
            "-a",
            f"{CONEXION_SCRIPT} {action}",
        ]
        notice = result_notice(run_command(stdscr, label, command))


def menu_energy(stdscr: "curses.window") -> None:
    actions = {
        "all_wake": ("wake", "all", (MACS_PB, MACS_PA), "Encender · Todas las aulas"),
        "all_shutdown": ("shutdown", "all", (), "Apagar · Todas las aulas"),
        "all_reboot": ("reboot", "all", (), "Reiniciar · Todas las aulas"),
        "pb_wake": ("wake", PLANTA_BAJA, (MACS_PB,), "Encender · Planta baja"),
        "pb_shutdown": ("shutdown", PLANTA_BAJA, (), "Apagar · Planta baja"),
        "pb_reboot": ("reboot", PLANTA_BAJA, (), "Reiniciar · Planta baja"),
        "pa_wake": ("wake", PLANTA_ALTA, (MACS_PA,), "Encender · Planta alta"),
        "pa_shutdown": ("shutdown", PLANTA_ALTA, (), "Apagar · Planta alta"),
        "pa_reboot": ("reboot", PLANTA_ALTA, (), "Reiniciar · Planta alta"),
    }
    notice = ""

    while True:
        choice = choose(
            stdscr,
            "Energía",
            "Elegí una acción para los equipos del laboratorio",
            ENERGY_OPTIONS,
            notice,
        )
        if choice in (None, "back"):
            return

        action, group, mac_files, label = actions[choice]
        if action == "wake":
            command = ["bash", str(PRENDER_AULA_SH), *mac_files]
        elif action == "shutdown":
            command = [
                "ansible",
                group,
                "-i",
                str(HOSTS),
                "-m",
                "shell",
                "-a",
                "sudo shutdown -h now",
            ]
        else:
            command = [
                "ansible",
                group,
                "-i",
                str(HOSTS),
                "-m",
                "shell",
                "-a",
                "sudo reboot",
            ]

        notice = result_notice(run_command(stdscr, label, command))


def menu_admin(stdscr: "curses.window") -> None:
    notice = ""

    while True:
        choice = choose(
            stdscr,
            "Administración",
            "Herramientas de diagnóstico y supervisión",
            ADMIN_OPTIONS,
            notice,
        )
        if choice in (None, "back"):
            return

        command = ["ansible", "all", "-i", str(HOSTS), "-m", "ping"]
        notice = result_notice(run_command(stdscr, "Estado de equipos · Ping", command))


def application(stdscr: "curses.window") -> None:
    init_screen(stdscr)
    initial_notice = ""
    if not HOSTS.is_file():
        initial_notice = f"Aviso: no se encontró {HOSTS.name}"

    while True:
        choice = choose(
            stdscr,
            "Menú principal",
            "Seleccioná una categoría",
            MAIN_OPTIONS,
            initial_notice,
        )
        initial_notice = ""

        if choice in (None, "exit"):
            return
        if choice == "firewall":
            menu_firewall(stdscr)
        elif choice == "energy":
            menu_energy(stdscr)
        elif choice == "admin":
            menu_admin(stdscr)


def main() -> int:
    try:
        locale.setlocale(locale.LC_ALL, "")
    except locale.Error:
        pass

    if not sys.stdin.isatty() or not sys.stdout.isatty():
        print("Este menú necesita ejecutarse en una terminal interactiva.", file=sys.stderr)
        return 1

    try:
        curses.wrapper(application)
    except KeyboardInterrupt:
        pass
    except curses.error as error:
        print(f"No se pudo iniciar la interfaz de terminal: {error}", file=sys.stderr)
        return 1

    print("Sesión de administración finalizada correctamente.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
