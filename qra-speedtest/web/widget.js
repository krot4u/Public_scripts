(function () {
  'use strict';
  const stages = ['tcp_upload', 'tcp_download', 'udp_upload', 'udp_download', 'dmr_upload', 'dmr_download'];
  const profileNames = {tcp: 'TCP', udp: 'UDP', dmr: 'DMR'};
  const directionNames = {upload: 'Передача', download: 'Приём'};
  const byId = id => document.getElementById(id);
  let csrf = null;
  let timer = null;
  let inFlight = false;

  function showError(message) {
    byId('error-message').textContent = message;
    byId('error-section').hidden = !message;
  }

  function verdict(tone, title, description) {
    byId('verdict').dataset.tone = tone;
    byId('verdict').setAttribute('aria-busy', String(tone === 'running'));
    if (byId('status-text').textContent !== title) byId('status-text').textContent = title;
    if (byId('verdict-description').textContent !== description) {
      byId('verdict-description').textContent = description;
    }
  }

  function connectionLost(error) {
    verdict('unknown', 'Нет связи с устройством', 'Повторяем подключение…');
    byId('start-btn').disabled = true;
    byId('start-btn').textContent = 'Подключение…';
    showError(error.message);
  }

  async function request(options = {}) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 7000);
    try {
      const response = await fetch('api.php', {...options, cache: 'no-store', signal: controller.signal});
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || `HTTP ${response.status}`);
      if (data.csrf) csrf = data.csrf;
      return data.state;
    } finally { clearTimeout(timeout); }
  }

  function renderResults(results) {
    byId('results-tbody').replaceChildren();
    byId('results-section').hidden = results.length === 0;
    for (const result of results) {
      const number = (value, digits) => value == null ? '—' : Number(value).toFixed(digits);
      const row = document.createElement('tr');
      const values = [profileNames[result.profile], directionNames[result.direction],
        number(result.mbps, result.profile === 'dmr' ? 4 : 2), number(result.jitter_ms, 2),
        number(result.lost_percent, 1), result.packets == null ? '—' : String(result.packets)];
      values.forEach((value, index) => {
        const cell = document.createElement('td');
        cell.textContent = value;
        if (index > 1) cell.className = 'numeric';
        row.appendChild(cell);
      });
      byId('results-tbody').appendChild(row);
    }
  }

  function render(state) {
    const running = state.status === 'running';
    const results = state.results || [];
    byId('start-btn').disabled = running || !csrf;
    byId('start-btn').textContent = running ? 'Проверяем…' : state.status === 'idle' ? 'Проверить связь' : 'Проверить снова';
    if (running) verdict('running', 'Проверяем связь', 'Тестируем передачу и приём');
    else if (state.status === 'idle') verdict('unknown', 'Связь с QRA-XLX', 'Нажмите кнопку, чтобы начать');
    else {
      const quality = window.QraLinkQuality.evaluate(state);
      verdict(quality.tone, quality.title, quality.description);
    }
    byId('progress-container').hidden = state.status === 'idle';
    byId('progress-list').replaceChildren();
    stages.forEach(stage => {
      const [profile, direction] = stage.split('_');
      const completed = results.some(item => item.profile === profile && item.direction === direction);
      const current = running && state.stage === stage && !completed;
      const item = document.createElement('li');
      item.textContent = `${profileNames[profile]} ${directionNames[direction].toLowerCase()}${current ? ' — сейчас' : ''}`;
      if (completed) item.className = 'completed';
      if (current) item.setAttribute('aria-current', 'step');
      byId('progress-list').appendChild(item);
    });
    renderResults(results);
    showError(state.error || '');
    return running;
  }

  function schedule() {
    clearTimeout(timer);
    timer = setTimeout(refresh, 1000);
  }

  async function refresh() {
    if (inFlight) return;
    inFlight = true;
    let again = true;
    try { again = render(await request()); }
    catch (error) { connectionLost(error); }
    finally {
      inFlight = false;
      if (again) schedule();
    }
  }

  async function start() {
    if (inFlight || !csrf) return;
    clearTimeout(timer);
    inFlight = true;
    byId('diagnostics').open = false;
    byId('start-btn').disabled = true;
    byId('start-btn').textContent = 'Запуск…';
    verdict('running', 'Запускаем проверку', '');
    renderResults([]);
    showError('');
    try {
      render(await request({method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({action: 'start', csrf})}));
    } catch (error) { connectionLost(error); }
    finally {
      // A lost POST response or busy response may still mean a running test.
      inFlight = false;
      schedule();
    }
  }

  byId('start-btn').addEventListener('click', start);
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && window.parent !== window) {
      event.preventDefault();
      window.parent.postMessage({type: 'qra-speedtest-close'}, window.location.origin);
    }
  });
  refresh();
})();
