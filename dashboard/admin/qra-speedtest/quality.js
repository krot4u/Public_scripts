(function (root) {
  'use strict';
  const unknown = {tone: 'unknown', title: 'Недостаточно данных',
    description: 'Повторите проверку, чтобы оценить связь.'};
  const finite = value => typeof value === 'number' && Number.isFinite(value);

  function evaluate(state) {
    if (state.status === 'error') {
      return {tone: 'poor', title: 'Проверка не завершена',
        description: 'Не удалось оценить связь. Повторите проверку.'};
    }
    const results = state.results || [];
    if (state.status !== 'done' || results.length !== 6) return unknown;
    for (const profile of ['tcp', 'udp', 'dmr']) {
      for (const direction of ['upload', 'download']) {
        const matches = results.filter(item => item.profile === profile && item.direction === direction);
        if (matches.length !== 1 || !finite(matches[0].mbps) || matches[0].mbps < 0) return unknown;
      }
    }
    const dmr = results.filter(item => item.profile === 'dmr');
    if (dmr.some(item => !finite(item.jitter_ms) || item.jitter_ms < 0 ||
      !finite(item.lost_percent) || item.lost_percent < 0 || item.lost_percent > 100 ||
      !Number.isInteger(item.packets) || item.packets <= 0)) return unknown;
    const loss = Math.max(...dmr.map(item => item.lost_percent));
    const jitter = Math.max(...dmr.map(item => item.jitter_ms));
    // Prototype heuristics for this synthetic DMR profile, not a protocol standard.
    if (loss >= 3 || jitter >= 50 || results.some(item => item.mbps === 0)) {
      return {tone: 'poor', title: 'Проблемы со связью',
        description: 'Возможны обрывы и пропуски голоса.'};
    }
    if (loss >= 1 || jitter >= 20) {
      return {tone: 'fair', title: 'Связь нестабильная',
        description: 'Голос может иногда прерываться.'};
    }
    return {tone: 'good', title: 'Связь хорошая',
      description: 'Тестовый поток DMR проходит стабильно.'};
  }

  const api = {evaluate};
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.QraLinkQuality = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
