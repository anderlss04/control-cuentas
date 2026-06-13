# Control de Cuentas — Prop Firms & Capital Propio

Panel personal (un solo archivo HTML, sin servidor) para no perder cuentas de prop firm por
inactividad ni por incumplir los días mínimos, y tener a la vista el profit de cada una.

## Uso

Abre `index.html` en el navegador. Los datos se guardan en el `localStorage` de **ese**
navegador (no viajan con el archivo). Usa el botón **⭳ Exportar** para hacer copia de seguridad.

> ⚠️ Las copias exportadas (`control-cuentas-*.json`) contienen tus datos reales y están
> excluidas del repositorio por `.gitignore`. No las subas.

## Funciones

- Seguimiento de **inactividad** con semáforo (🟢🟡🔴) y alertas automáticas.
- **Días mínimos** por ciclo con barra de progreso y botón "Operé hoy".
- **Profit** por cuenta y total, progreso al profit target.
- Reglas **precargadas (jun 2026)** de The5ers, WSFunded, Lucid Trading y Topstep
  (inactividad, días mínimos, drawdown, daily loss, payout) — selector firm → programa.

Las reglas son una referencia editable; **verifica siempre con tu firm**, cambian a menudo.

## Privacidad

El HTML desplegado es solo el "envoltorio": no contiene ningún dato personal. Cada persona que
abra la web ve su propio panel vacío en su navegador. Tus cuentas viven solo en tu localStorage.
