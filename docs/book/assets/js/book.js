(function(){
  const q = document.getElementById('q');
  if(!q) return;
  q.addEventListener('input', () => {
    const term = q.value.toLowerCase().trim();
    document.querySelectorAll('.nav a[data-title]').forEach(a => {
      const t = (a.getAttribute('data-title')||'').toLowerCase();
      a.style.display = (!term || t.includes(term)) ? 'block' : 'none';
    });
  });
})();
