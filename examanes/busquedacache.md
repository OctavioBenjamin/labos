# Instrucciones para la busqueda de cache de firefox

1. Ir a la carpeta `~/snap/firefox/common/.cache/mozilla/firefox/*.default*/cache2/entries`
2. Filtrar el cache por tiempo y grepear el contenido.
```sh
find . -newermt "aaaa-mm-dd hh:mm:ss ! -newermt "aaaa-mm-dd hh:mm:ss -exec strings -f {} + | grep -iE "gemini|chatgpt|deepseek|copilot"
```


