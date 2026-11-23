const a = document.createElement('a');
a.href = new URLSearchParams(location.search).get('to');
a.textContent = a.href;
document.body.append(a);
a.click();
