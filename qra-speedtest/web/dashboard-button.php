<?php
/**
 * QRA-XLX Speedtest Widget Button
 * Include-файл для встраивания кнопки проверки связи в Pi-Star дашборд
 */
?>
<dialog id="qra-speedtest-dialog" class="qra-speedtest-dialog" aria-label="Проверка связи с QRA-XLX">
  <iframe
    data-src="/admin/qra-speedtest/widget.html?v=2"
    class="qra-speedtest-iframe"
    title="Проверка связи с QRA-XLX"
  ></iframe>
  <button type="button" class="qra-speedtest-close" aria-label="Закрыть" autofocus>×</button>
</dialog>

<button type="button" id="qra-speedtest-btn" class="qra-speedtest-btn">
  Проверить связь XLX
</button>

<style>
.qra-speedtest-btn {
  box-sizing: border-box;
  display: block;
  width: 100%;
  margin: 14px 0 4px;
  padding: 8px 12px;
  max-width: 100%;
  font-family: verdana, arial, sans-serif;
  font-size: 12px;
  font-weight: 400;
  color: #5bc0de;
  background-color: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(91, 192, 222, 0.4);
  border-radius: 6px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  transition: background-color 150ms ease, border-color 150ms ease, box-shadow 150ms ease;
}

.qra-speedtest-btn:hover {
  background-color: rgba(91, 192, 222, 0.1);
  border-color: rgba(91, 192, 222, 0.6);
}

.qra-speedtest-btn:active {
  background-color: rgba(91, 192, 222, 0.15);
  border-color: rgba(91, 192, 222, 0.8);
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.15);
}

.qra-speedtest-btn:focus-visible {
  outline: 2px solid #5bc0de;
  outline-offset: 2px;
}

@media (prefers-reduced-motion: reduce) {
  .qra-speedtest-btn {
    transition: none;
  }
}

.qra-speedtest-dialog {
  max-width: 90vw;
  max-height: 90vh;
  width: 500px;
  padding: 0;
  border: 1px solid #3a4448;
  border-radius: 8px;
  background-color: #242d31;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
}

.qra-speedtest-dialog:modal { overscroll-behavior: contain; }

.qra-speedtest-dialog::backdrop {
  background-color: rgba(0, 0, 0, 0.5);
  overflow: hidden;
  overscroll-behavior: contain;
}

.qra-speedtest-iframe {
  width: 100%;
  height: 450px;
  border: none;
  border-radius: 8px 8px 0 0;
}

.qra-speedtest-close {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 32px;
  height: 32px;
  padding: 0;
  font-family: verdana, arial, sans-serif;
  font-size: 24px;
  line-height: 1;
  color: #ffffff;
  background-color: rgba(0, 0, 0, 0.5);
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.qra-speedtest-close:hover {
  background-color: rgba(0, 0, 0, 0.7);
}

.qra-speedtest-close:focus-visible {
  outline: 2px solid #4a90e2;
  outline-offset: 2px;
}

@media (max-width: 680px) {
  .qra-speedtest-dialog {
    width: calc(100vw - 24px);
    max-width: 500px;
    max-height: calc(100dvh - 24px);
    margin: auto;
  }

  .qra-speedtest-iframe {
    height: min(450px, calc(100dvh - 32px));
  }
}
</style>

<script>
(function() {
  'use strict';

  const btn = document.getElementById('qra-speedtest-btn');
  const dialog = document.getElementById('qra-speedtest-dialog');
  const closeBtn = dialog.querySelector('.qra-speedtest-close');
  const frame = dialog.querySelector('iframe');

  function openDialog() {
    if (!frame.hasAttribute('src')) frame.src = frame.dataset.src;
    dialog.showModal();
  }

  function closeDialog() {
    dialog.close();
  }

  btn.addEventListener('click', openDialog);
  closeBtn.addEventListener('click', closeDialog);

  window.addEventListener('message', function(event) {
    if (event.origin === location.origin && event.source === frame.contentWindow &&
        event.data && event.data.type === 'qra-speedtest-close') closeDialog();
  });
})();
</script>
