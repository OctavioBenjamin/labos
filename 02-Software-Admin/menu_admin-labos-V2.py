#!/usr/bin/env python3
"""Panel gráfico para la administración centralizada de los laboratorios UNC."""

from __future__ import annotations

import queue
import shlex
import subprocess
import sys
import threading
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Callable, Optional, Sequence

try:
    import tkinter as tk
    from tkinter import messagebox
    from tkinter.scrolledtext import ScrolledText
except ImportError as error:
    print(
        "No se encontró Tkinter. En Debian/Ubuntu instalalo con: "
        "sudo apt install python3-tk",
        file=sys.stderr,
    )
    raise SystemExit(1) from error


SCRIPT_DIR = Path(__file__).resolve().parent
BASE_DIR = SCRIPT_DIR.parent

HOSTS = SCRIPT_DIR / "ansible" / "hosts.ini"
PLANTA_BAJA = "planta_baja"
PLANTA_ALTA = "planta_alta"

MACS_PA = "MACs_PA.txt"
MACS_PB = "MACs_PB.txt"

CONEXION_SCRIPT = "sudo /etc/psico/fw_conexion.sh"
PRENDER_AULA_SH = SCRIPT_DIR / "wake_aula-completa.sh"


COLORS = {
    "background": "#08111F",
    "sidebar": "#0C1728",
    "surface": "#101D31",
    "card": "#14243B",
    "card_hover": "#1A2E4A",
    "border": "#233955",
    "text": "#F5F8FC",
    "muted": "#91A4BC",
    "blue": "#3B82F6",
    "cyan": "#22D3C5",
    "green": "#34D399",
    "red": "#FB7185",
    "amber": "#FBBF24",
    "console": "#07101C",
}


@dataclass(frozen=True)
class CommandAction:
    title: str
    detail: str
    command: tuple[str, ...]


def firewall_command(group: str, action: str) -> tuple[str, ...]:
    return (
        "ansible",
        group,
        "-i",
        str(HOSTS),
        "-m",
        "shell",
        "-a",
        f"{CONEXION_SCRIPT} {action}",
    )


def wake_command(mac_files: Sequence[str]) -> tuple[str, ...]:
    return ("bash", str(PRENDER_AULA_SH), *mac_files)


def shutdown_command(group: str) -> tuple[str, ...]:
    return (
        "ansible",
        group,
        "-i",
        str(HOSTS),
        "-m",
        "shell",
        "-a",
        "sudo shutdown -h now",
    )


def reboot_command(group: str) -> tuple[str, ...]:
    return (
        "ansible",
        group,
        "-i",
        str(HOSTS),
        "-m",
        "shell",
        "-a",
        "sudo reboot",
    )


def ping_command(group: str = "all") -> tuple[str, ...]:
    return ("ansible", group, "-i", str(HOSTS), "-m", "ping")


class LabosAdminApp:
    PAGE_INFO = {
        "dashboard": ("Panel principal", "Resumen de herramientas disponibles"),
        "firewall": ("Firewall y Red", "Control de conectividad por sector"),
        "energy": ("Energía", "Encendido y control remoto de equipos"),
        "admin": ("Administración", "Diagnóstico del inventario Ansible"),
    }

    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("Laboratorio UNC · Gestión centralizada")
        self.root.geometry("1180x780")
        self.root.minsize(980, 680)
        self.root.configure(bg=COLORS["background"])
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

        self.events: "queue.Queue[tuple[str, object]]" = queue.Queue()
        self.current_process: Optional[subprocess.Popen[str]] = None
        self.busy = False
        self.current_page = "dashboard"
        self.action_buttons: list[tk.Button] = []
        self.nav_buttons: dict[str, tk.Button] = {}
        self.nav_markers: dict[str, tk.Frame] = {}

        self._build_layout()
        self.show_page("dashboard")
        self._write_initial_messages()
        self.root.after(100, self._poll_events)

    def _build_layout(self) -> None:
        self.sidebar = tk.Frame(
            self.root, bg=COLORS["sidebar"], width=230, highlightthickness=0
        )
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)
        self.sidebar.pack_propagate(False)

        self.workspace = tk.Frame(self.root, bg=COLORS["background"])
        self.workspace.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.workspace.grid_columnconfigure(0, weight=1)
        self.workspace.grid_rowconfigure(1, weight=1)

        self._build_sidebar()
        self._build_topbar()

        self.page_container = tk.Frame(self.workspace, bg=COLORS["background"])
        self.page_container.grid(row=1, column=0, sticky="nsew", padx=26, pady=(8, 16))

        self._build_console()

    def _build_sidebar(self) -> None:
        brand = tk.Frame(self.sidebar, bg=COLORS["sidebar"], height=104)
        brand.pack(fill=tk.X, padx=20, pady=(20, 10))
        brand.pack_propagate(False)

        logo = tk.Label(
            brand,
            text="UNC",
            bg=COLORS["blue"],
            fg="white",
            font=("DejaVu Sans", 12, "bold"),
            width=5,
            height=2,
        )
        logo.pack(side=tk.LEFT, pady=11)

        brand_text = tk.Frame(brand, bg=COLORS["sidebar"])
        brand_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(12, 0), pady=14)
        tk.Label(
            brand_text,
            text="LABORATORIOS",
            bg=COLORS["sidebar"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 10, "bold"),
            anchor="w",
        ).pack(fill=tk.X)
        tk.Label(
            brand_text,
            text="Gestión central",
            bg=COLORS["sidebar"],
            fg=COLORS["muted"],
            font=("DejaVu Sans", 9),
            anchor="w",
        ).pack(fill=tk.X, pady=(2, 0))

        tk.Label(
            self.sidebar,
            text="NAVEGACIÓN",
            bg=COLORS["sidebar"],
            fg=COLORS["muted"],
            font=("DejaVu Sans", 8, "bold"),
            anchor="w",
        ).pack(fill=tk.X, padx=24, pady=(12, 8))

        nav_items = (
            ("dashboard", "▦", "Panel principal"),
            ("firewall", "⌁", "Firewall y Red"),
            ("energy", "ϟ", "Energía"),
            ("admin", "◎", "Administración"),
        )
        for page, icon, label in nav_items:
            self._create_nav_button(page, icon, label)

        footer = tk.Frame(
            self.sidebar,
            bg=COLORS["surface"],
            highlightbackground=COLORS["border"],
            highlightthickness=1,
        )
        footer.pack(side=tk.BOTTOM, fill=tk.X, padx=16, pady=18)

        inventory_ok = HOSTS.is_file()
        dot_color = COLORS["green"] if inventory_ok else COLORS["amber"]
        inventory_text = "Inventario disponible" if inventory_ok else "Falta hosts.ini"
        tk.Label(
            footer,
            text="●",
            bg=COLORS["surface"],
            fg=dot_color,
            font=("DejaVu Sans", 11),
        ).pack(side=tk.LEFT, padx=(12, 8), pady=12)
        tk.Label(
            footer,
            text=inventory_text,
            bg=COLORS["surface"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 9),
            anchor="w",
        ).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 8))

    def _create_nav_button(self, page: str, icon: str, label: str) -> None:
        holder = tk.Frame(self.sidebar, bg=COLORS["sidebar"], height=48)
        holder.pack(fill=tk.X, padx=12, pady=2)
        holder.pack_propagate(False)

        marker = tk.Frame(holder, bg=COLORS["sidebar"], width=4)
        marker.pack(side=tk.LEFT, fill=tk.Y)
        self.nav_markers[page] = marker

        button = tk.Button(
            holder,
            text=f"  {icon}    {label}",
            command=lambda selected=page: self.show_page(selected),
            bg=COLORS["sidebar"],
            activebackground=COLORS["card"],
            fg=COLORS["muted"],
            activeforeground=COLORS["text"],
            font=("DejaVu Sans", 10),
            anchor="w",
            relief=tk.FLAT,
            bd=0,
            highlightthickness=0,
            cursor="hand2",
        )
        button.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.nav_buttons[page] = button

    def _build_topbar(self) -> None:
        topbar = tk.Frame(self.workspace, bg=COLORS["background"], height=88)
        topbar.grid(row=0, column=0, sticky="ew", padx=26, pady=(12, 0))
        topbar.grid_columnconfigure(0, weight=1)
        topbar.grid_propagate(False)

        text_holder = tk.Frame(topbar, bg=COLORS["background"])
        text_holder.grid(row=0, column=0, sticky="w", pady=12)
        self.page_title = tk.Label(
            text_holder,
            text="",
            bg=COLORS["background"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 20, "bold"),
            anchor="w",
        )
        self.page_title.pack(fill=tk.X)
        self.page_subtitle = tk.Label(
            text_holder,
            text="",
            bg=COLORS["background"],
            fg=COLORS["muted"],
            font=("DejaVu Sans", 10),
            anchor="w",
        )
        self.page_subtitle.pack(fill=tk.X, pady=(3, 0))

        self.status_pill = tk.Label(
            topbar,
            text="  ●  SISTEMA LISTO  ",
            bg="#12352F",
            fg=COLORS["green"],
            font=("DejaVu Sans", 9, "bold"),
            padx=10,
            pady=8,
        )
        self.status_pill.grid(row=0, column=1, sticky="e", pady=20)

    def _build_console(self) -> None:
        console_frame = tk.Frame(
            self.workspace,
            bg=COLORS["surface"],
            height=244,
            highlightbackground=COLORS["border"],
            highlightthickness=1,
        )
        console_frame.grid(row=2, column=0, sticky="ew", padx=26, pady=(0, 22))
        console_frame.grid_propagate(False)
        console_frame.grid_columnconfigure(0, weight=1)
        console_frame.grid_rowconfigure(1, weight=1)

        console_header = tk.Frame(console_frame, bg=COLORS["surface"], height=44)
        console_header.grid(row=0, column=0, sticky="ew")
        console_header.grid_columnconfigure(1, weight=1)
        console_header.grid_propagate(False)

        tk.Label(
            console_header,
            text="●",
            bg=COLORS["surface"],
            fg=COLORS["cyan"],
            font=("DejaVu Sans", 10),
        ).grid(row=0, column=0, padx=(14, 8), pady=12)
        tk.Label(
            console_header,
            text="ACTIVIDAD DEL SISTEMA",
            bg=COLORS["surface"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 9, "bold"),
            anchor="w",
        ).grid(row=0, column=1, sticky="w")
        tk.Button(
            console_header,
            text="Limpiar",
            command=self.clear_console,
            bg=COLORS["surface"],
            activebackground=COLORS["card"],
            fg=COLORS["muted"],
            activeforeground=COLORS["text"],
            font=("DejaVu Sans", 9),
            relief=tk.FLAT,
            bd=0,
            cursor="hand2",
        ).grid(row=0, column=2, padx=12)

        self.console = ScrolledText(
            console_frame,
            bg=COLORS["console"],
            fg="#C7D5E5",
            insertbackground=COLORS["text"],
            font=("DejaVu Sans Mono", 9),
            relief=tk.FLAT,
            bd=0,
            padx=14,
            pady=10,
            wrap=tk.WORD,
            state=tk.DISABLED,
        )
        self.console.grid(row=1, column=0, sticky="nsew")
        self.console.tag_configure("time", foreground="#647A94")
        self.console.tag_configure("command", foreground=COLORS["cyan"])
        self.console.tag_configure("success", foreground=COLORS["green"])
        self.console.tag_configure("warning", foreground=COLORS["amber"])
        self.console.tag_configure("error", foreground=COLORS["red"])
        self.console.tag_configure("muted", foreground=COLORS["muted"])

    def show_page(self, page: str) -> None:
        self.current_page = page
        title, subtitle = self.PAGE_INFO[page]
        self.page_title.configure(text=title)
        self.page_subtitle.configure(text=subtitle)

        for name, button in self.nav_buttons.items():
            active = name == page
            button.configure(
                bg=COLORS["card"] if active else COLORS["sidebar"],
                fg=COLORS["text"] if active else COLORS["muted"],
                font=("DejaVu Sans", 10, "bold" if active else "normal"),
            )
            self.nav_markers[name].configure(
                bg=COLORS["blue"] if active else COLORS["sidebar"]
            )

        for child in self.page_container.winfo_children():
            child.destroy()
        self.action_buttons = []
        self._reset_page_layout()

        if page == "dashboard":
            self._render_dashboard()
        elif page == "firewall":
            self._render_firewall()
        elif page == "energy":
            self._render_energy()
        elif page == "admin":
            self._render_admin()

        # Aplica la nueva geometría dentro del mismo clic y evita un frame en blanco.
        self.page_container.update_idletasks()

    def _reset_page_layout(self) -> None:
        """Elimina la configuración de grilla heredada de la pantalla anterior."""
        for column in range(3):
            self.page_container.grid_columnconfigure(
                column, weight=0, minsize=0, pad=0, uniform=""
            )
        self.page_container.grid_rowconfigure(
            0, weight=0, minsize=0, pad=0, uniform=""
        )

    def _render_dashboard(self) -> None:
        for column in range(3):
            self.page_container.grid_columnconfigure(
                column, weight=1, uniform="dashboard"
            )
        self.page_container.grid_rowconfigure(0, weight=1)

        cards = (
            (
                "firewall",
                "⌁",
                "Firewall y Red",
                "6 acciones",
                "Habilitá o restringí Internet para todo el laboratorio o por planta.",
                COLORS["blue"],
            ),
            (
                "energy",
                "ϟ",
                "Energía",
                "9 acciones",
                "Encendé por Wake-on-LAN, apagá o reiniciá los equipos remotamente.",
                COLORS["amber"],
            ),
            (
                "admin",
                "◎",
                "Administración",
                "Diagnóstico",
                "Consultá rápidamente la disponibilidad de todos los hosts de Ansible.",
                COLORS["cyan"],
            ),
        )

        for column, card in enumerate(cards):
            self._dashboard_card(column, *card)

    def _dashboard_card(
        self,
        column: int,
        page: str,
        icon: str,
        title: str,
        count: str,
        description: str,
        accent: str,
    ) -> None:
        card = tk.Frame(
            self.page_container,
            bg=COLORS["card"],
            highlightbackground=COLORS["border"],
            highlightthickness=1,
        )
        card.grid(row=0, column=column, sticky="nsew", padx=(0 if column == 0 else 8, 0 if column == 2 else 8))

        accent_bar = tk.Frame(card, bg=accent, height=4)
        accent_bar.pack(fill=tk.X)

        tk.Label(
            card,
            text=icon,
            bg=COLORS["card"],
            fg=accent,
            font=("DejaVu Sans", 32, "bold"),
            anchor="w",
        ).pack(fill=tk.X, padx=22, pady=(20, 6))
        tk.Label(
            card,
            text=count.upper(),
            bg=COLORS["card"],
            fg=accent,
            font=("DejaVu Sans", 8, "bold"),
            anchor="w",
        ).pack(fill=tk.X, padx=22)
        tk.Label(
            card,
            text=title,
            bg=COLORS["card"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 14, "bold"),
            anchor="w",
        ).pack(fill=tk.X, padx=22, pady=(7, 8))
        tk.Label(
            card,
            text=description,
            bg=COLORS["card"],
            fg=COLORS["muted"],
            font=("DejaVu Sans", 9),
            justify=tk.LEFT,
            anchor="nw",
            wraplength=220,
        ).pack(fill=tk.BOTH, expand=True, padx=22)
        tk.Button(
            card,
            text="Abrir módulo  →",
            command=lambda selected=page: self.show_page(selected),
            bg=COLORS["surface"],
            activebackground=COLORS["card_hover"],
            fg=COLORS["text"],
            activeforeground=accent,
            font=("DejaVu Sans", 9, "bold"),
            relief=tk.FLAT,
            bd=0,
            padx=14,
            pady=10,
            cursor="hand2",
        ).pack(fill=tk.X, padx=22, pady=20)

    def _render_firewall(self) -> None:
        scopes = (
            ("TODO", "Todos los equipos", "all", COLORS["blue"]),
            ("PB", "Planta baja", PLANTA_BAJA, COLORS["cyan"]),
            ("PA", "Planta alta", PLANTA_ALTA, COLORS["green"]),
        )
        for column in range(3):
            self.page_container.grid_columnconfigure(column, weight=1, uniform="scope")
        self.page_container.grid_rowconfigure(0, weight=1)

        for column, (badge, title, group, accent) in enumerate(scopes):
            panel, actions = self._scope_panel(column, badge, title, "Control de Internet", accent)
            activate = CommandAction(
                f"Activar Internet · {title}",
                "Acceso completo habilitado",
                firewall_command(group, "on"),
            )
            deactivate = CommandAction(
                f"Desactivar Internet · {title}",
                "Acceso restringido a intranet",
                firewall_command(group, "off"),
            )
            self._action_button(actions, "Activar Internet", "Acceso completo", activate, "green")
            self._action_button(actions, "Desactivar Internet", "Solo intranet", deactivate, "red")

    def _render_energy(self) -> None:
        scopes = (
            ("TODO", "Todas las aulas", "all", (MACS_PB, MACS_PA), COLORS["blue"]),
            ("PB", "Planta baja", PLANTA_BAJA, (MACS_PB,), COLORS["cyan"]),
            ("PA", "Planta alta", PLANTA_ALTA, (MACS_PA,), COLORS["green"]),
        )
        for column in range(3):
            self.page_container.grid_columnconfigure(column, weight=1, uniform="scope")
        self.page_container.grid_rowconfigure(0, weight=1)

        for column, (badge, title, group, mac_files, accent) in enumerate(scopes):
            panel, actions = self._scope_panel(column, badge, title, "Control de energía", accent)
            wake = CommandAction(
                f"Encender · {title}",
                "Wake-on-LAN",
                wake_command(mac_files),
            )
            shutdown = CommandAction(
                f"Apagar · {title}",
                "Apagado remoto",
                shutdown_command(group),
            )
            reboot = CommandAction(
                f"Reiniciar · {title}",
                "Reinicio remoto",
                reboot_command(group),
            )
            self._action_button(actions, "Encender", "Wake-on-LAN", wake, "blue")
            self._action_button(actions, "Apagar", "Shutdown remoto", shutdown, "red")
            self._action_button(actions, "Reiniciar", "Reboot remoto", reboot, "amber")

    def _render_admin(self) -> None:
        scopes = (
            ("TODO", "Todos los equipos", "all", "blue", COLORS["blue"]),
            ("PB", "Planta baja", PLANTA_BAJA, "cyan", COLORS["cyan"]),
            ("PA", "Planta alta", PLANTA_ALTA, "green", COLORS["green"]),
        )
        for column in range(3):
            self.page_container.grid_columnconfigure(column, weight=1, uniform="scope")
        self.page_container.grid_rowconfigure(0, weight=1)

        for column, (badge, title, group, color_name, accent) in enumerate(scopes):
            panel, actions = self._scope_panel(
                column, badge, title, "Diagnóstico Ansible", accent
            )
            action = CommandAction(
                f"Estado de equipos · {title}",
                f"Ansible ping · {group}",
                ping_command(group),
            )
            self._action_button(
                actions,
                "Verificar equipos",
                f"Ansible ping · {group}",
                action,
                color_name,
            )

    def _scope_panel(
        self,
        column: int,
        badge: str,
        title: str,
        subtitle: str,
        accent: str,
    ) -> tuple[tk.Frame, tk.Frame]:
        panel = tk.Frame(
            self.page_container,
            bg=COLORS["card"],
            highlightbackground=COLORS["border"],
            highlightthickness=1,
        )
        panel.grid(
            row=0,
            column=column,
            sticky="nsew",
            padx=(0 if column == 0 else 8, 0 if column == 2 else 8),
        )
        tk.Frame(panel, bg=accent, height=4).pack(fill=tk.X)

        header = tk.Frame(panel, bg=COLORS["card"])
        header.pack(fill=tk.X, padx=18, pady=(18, 14))
        tk.Label(
            header,
            text=badge,
            bg=accent,
            fg=COLORS["background"],
            font=("DejaVu Sans", 8, "bold"),
            padx=8,
            pady=4,
        ).pack(anchor="w")
        tk.Label(
            header,
            text=title,
            bg=COLORS["card"],
            fg=COLORS["text"],
            font=("DejaVu Sans", 13, "bold"),
            anchor="w",
        ).pack(fill=tk.X, pady=(10, 2))
        tk.Label(
            header,
            text=subtitle,
            bg=COLORS["card"],
            fg=COLORS["muted"],
            font=("DejaVu Sans", 9),
            anchor="w",
        ).pack(fill=tk.X)

        tk.Frame(panel, bg=COLORS["border"], height=1).pack(fill=tk.X, padx=18)
        actions = tk.Frame(panel, bg=COLORS["card"])
        actions.pack(fill=tk.BOTH, expand=True, padx=18, pady=16)
        return panel, actions

    def _action_button(
        self,
        parent: tk.Misc,
        title: str,
        subtitle: str,
        action: CommandAction,
        color_name: str,
        width: Optional[int] = None,
    ) -> tk.Button:
        accent = COLORS[color_name]
        button = tk.Button(
            parent,
            text=f"{title}\n{subtitle}",
            command=lambda selected=action: self.run_action(selected),
            bg=COLORS["surface"],
            activebackground=COLORS["card_hover"],
            fg=accent,
            activeforeground=COLORS["text"],
            disabledforeground=COLORS["muted"],
            font=("DejaVu Sans", 10, "bold"),
            justify=tk.LEFT,
            anchor="w",
            relief=tk.FLAT,
            bd=0,
            highlightthickness=0,
            padx=14,
            pady=10,
            cursor="hand2",
            width=width or 0,
            state=tk.DISABLED if self.busy else tk.NORMAL,
        )
        button.pack(fill=tk.X, pady=5)
        self.action_buttons.append(button)
        return button

    def run_action(self, action: CommandAction) -> None:
        if self.busy:
            self._append_console("Ya hay una acción en ejecución.\n", "warning")
            return

        self.busy = True
        self._set_action_buttons(tk.DISABLED)
        self._set_status("EJECUTANDO", COLORS["amber"], "#3A2B0D")
        self._append_timestamp()
        self._append_console(f" {action.title}\n", "command")
        self._append_console(f"$ {shlex.join(action.command)}\n\n", "muted")

        worker = threading.Thread(
            target=self._command_worker,
            args=(action,),
            daemon=True,
            name="labos-command",
        )
        worker.start()

    def _command_worker(self, action: CommandAction) -> None:
        try:
            process = subprocess.Popen(
                action.command,
                cwd=str(SCRIPT_DIR),
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                bufsize=1,
            )
            self.current_process = process
            if process.stdout is not None:
                for line in process.stdout:
                    self.events.put(("output", line))
            result_code = process.wait()
            self.events.put(("done", (action.title, result_code)))
        except FileNotFoundError:
            self.events.put(("error", f"No se encontró el comando: {action.command[0]}"))
            self.events.put(("done", (action.title, 127)))
        except OSError as error:
            self.events.put(("error", f"No se pudo ejecutar la acción: {error}"))
            self.events.put(("done", (action.title, 1)))
        finally:
            self.current_process = None

    def _poll_events(self) -> None:
        try:
            while True:
                event, payload = self.events.get_nowait()
                if event == "output":
                    self._append_console(str(payload))
                elif event == "error":
                    self._append_console(f"✕ {payload}\n", "error")
                elif event == "done":
                    title, result_code = payload  # type: ignore[misc]
                    self._finish_action(str(title), int(result_code))
        except queue.Empty:
            pass

        if self.root.winfo_exists():
            self.root.after(100, self._poll_events)

    def _finish_action(self, title: str, result_code: int) -> None:
        self.busy = False
        self._set_action_buttons(tk.NORMAL)
        if result_code == 0:
            self._append_console("\n✓ Acción finalizada correctamente.\n", "success")
            self._set_status("SISTEMA LISTO", COLORS["green"], "#12352F")
        else:
            self._append_console(
                f"\n! La acción terminó con código {result_code}.\n", "warning"
            )
            self._set_status("REVISAR SALIDA", COLORS["amber"], "#3A2B0D")
        self._append_console("─" * 72 + "\n", "muted")

    def _set_action_buttons(self, state: str) -> None:
        for button in self.action_buttons:
            if button.winfo_exists():
                button.configure(state=state)

    def _set_status(self, text: str, foreground: str, background: str) -> None:
        self.status_pill.configure(
            text=f"  ●  {text}  ", fg=foreground, bg=background
        )

    def _append_timestamp(self) -> None:
        timestamp = datetime.now().strftime("[%H:%M:%S]")
        self._append_console(timestamp, "time")

    def _append_console(self, text: str, tag: Optional[str] = None) -> None:
        self.console.configure(state=tk.NORMAL)
        if tag:
            self.console.insert(tk.END, text, tag)
        else:
            self.console.insert(tk.END, text)
        self.console.see(tk.END)
        self.console.configure(state=tk.DISABLED)

    def clear_console(self) -> None:
        self.console.configure(state=tk.NORMAL)
        self.console.delete("1.0", tk.END)
        self.console.configure(state=tk.DISABLED)

    def _write_initial_messages(self) -> None:
        self._append_timestamp()
        self._append_console(" Panel de administración iniciado.\n", "success")
        if not HOSTS.is_file():
            self._append_console(
                f"! No se encontró el inventario: {HOSTS}\n", "warning"
            )
        if not PRENDER_AULA_SH.is_file():
            self._append_console(
                f"! No se encontró el script Wake-on-LAN: {PRENDER_AULA_SH}\n",
                "warning",
            )
        self._append_console("Seleccioná un módulo para comenzar.\n", "muted")

    def on_close(self) -> None:
        if self.busy:
            close_anyway = messagebox.askyesno(
                "Acción en ejecución",
                "Hay una acción todavía en ejecución. ¿Querés detenerla y cerrar?",
                parent=self.root,
            )
            if not close_anyway:
                return
            if self.current_process is not None:
                try:
                    self.current_process.terminate()
                except OSError:
                    pass
        self.root.destroy()


def main() -> int:
    try:
        root = tk.Tk()
    except tk.TclError as error:
        print(
            "No se pudo iniciar la interfaz gráfica. Verificá que exista una sesión "
            f"gráfica o una variable DISPLAY válida: {error}",
            file=sys.stderr,
        )
        return 1

    LabosAdminApp(root)
    root.mainloop()
    print("Sesión de administración finalizada correctamente.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
