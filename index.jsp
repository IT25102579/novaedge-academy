<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // If already logged in, redirect to courses
    String role = (String) session.getAttribute("role");
    if (role != null) {
        if ("admin".equals(role)) { response.sendRedirect("admin.jsp"); return; }
        else                      { response.sendRedirect("courses.jsp"); return; }
    }
    String loginError = (String) session.getAttribute("loginError");
    if (loginError != null) session.removeAttribute("loginError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>NovaEdge Academy — Charting the Edge of Learning</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,300;9..144,400&family=Inter:wght@300;400;500;600&family=JetBrains+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
  :root{--bg:#0a0b0d;--bg-2:#101216;--ink:#e9eaec;--ink-dim:#8a8f99;--line:rgba(233,234,236,0.10);--line-strong:rgba(233,234,236,0.22);--accent:#7cf0d0;--accent-soft:rgba(124,240,208,0.12);--danger:#ff6b6b;}
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{background:var(--bg);color:var(--ink);font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden;height:100%}
  a{color:inherit;text-decoration:none}
  ::selection{background:var(--accent);color:#0a0b0d}
  body::before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;background:radial-gradient(60% 40% at 20% 10%,rgba(124,240,208,0.08),transparent 60%),radial-gradient(50% 50% at 90% 90%,rgba(120,90,255,0.06),transparent 60%);}

  /* NAV */
  .nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;align-items:center;padding:22px 40px;backdrop-filter:blur(10px);background:linear-gradient(180deg,rgba(10,11,13,0.85),rgba(10,11,13,0));}
  .brand{display:flex;align-items:center;gap:12px;font-family:'Fraunces',serif;font-weight:400;font-size:18px;letter-spacing:.02em}
  .brand-mark{width:26px;height:26px;border:1px solid var(--ink);border-radius:50%;display:grid;place-items:center;}
  .brand-mark::after{content:"";width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 14px var(--accent);animation:pulse 3s ease-in-out infinite;}
  .nav-actions{display:flex;gap:12px;align-items:center}
  .btn-ghost{border:1px solid var(--line-strong);padding:10px 20px;border-radius:999px;font-size:13px;color:var(--ink);background:transparent;cursor:pointer;font-family:'JetBrains Mono',monospace;letter-spacing:.1em;transition:all .3s ease;}
  .btn-ghost:hover{background:rgba(255,255,255,0.06);border-color:var(--ink)}
  .btn-accent{border:1px solid var(--accent);padding:10px 20px;border-radius:999px;font-size:13px;color:#0a0b0d;background:var(--accent);cursor:pointer;font-family:'JetBrains Mono',monospace;letter-spacing:.1em;display:inline-flex;align-items:center;gap:8px;transition:all .3s ease;}
  .btn-accent:hover{filter:brightness(1.1)}
  .btn-accent .dot{width:6px;height:6px;border-radius:50%;background:#0a0b0d;}

  /* HERO */
  .hero{position:relative;z-index:1;min-height:100vh;display:flex;flex-direction:column;justify-content:center;align-items:flex-start;padding:0 40px 80px;border-bottom:1px solid var(--line);}
  .ticks{position:absolute;inset:0;pointer-events:none;z-index:0}
  .ticks::before,.ticks::after{content:"";position:absolute;width:14px;height:14px;border:1px solid var(--line-strong);}
  .ticks::before{top:120px;left:40px;border-right:0;border-bottom:0}
  .ticks::after{bottom:60px;right:40px;border-left:0;border-top:0}
  .eyebrow{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.18em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:24px;display:flex;align-items:center;gap:10px;}
  .eyebrow::before{content:"";width:24px;height:1px;background:var(--accent)}
  h1{font-family:'Fraunces',serif;font-weight:300;font-size:clamp(80px,8vw,120px);line-height:.93;letter-spacing:-0.02em;margin-bottom:32px;}
  h1 em{font-style:italic;color:var(--accent);font-weight:300}
  .hero-sub{max-width:480px;font-size:15px;color:var(--ink-dim);line-height:1.65;margin-bottom:48px;}
  .hero-cta{display:flex;gap:14px;flex-wrap:wrap}

  /* STAT BAR */
  .stat-bar{position:absolute;bottom:0;left:0;right:0;display:flex;border-top:1px solid var(--line);font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;}
  .stat{flex:1;padding:18px 24px;border-right:1px solid var(--line);display:flex;flex-direction:column;gap:4px;}
  .stat:last-child{border-right:0}
  .stat span{color:var(--ink);font-size:13px}

  /* ERROR TOAST */
  .error-bar{background:rgba(255,107,107,0.12);border:1px solid rgba(255,107,107,0.3);border-radius:12px;padding:14px 20px;margin-bottom:24px;font-size:13px;color:var(--danger);display:flex;align-items:center;gap:10px;max-width:480px;}

  /* MODAL */
  .modal-wrap{position:fixed;inset:0;background:rgba(5,6,8,0.75);backdrop-filter:blur(14px);z-index:100;display:none;align-items:center;justify-content:center;padding:24px;opacity:0;transition:opacity .4s ease;}
  .modal-wrap.open{display:flex;opacity:1}
  .modal{background:var(--bg-2);border:1px solid var(--line-strong);border-radius:18px;width:100%;max-width:420px;padding:40px;position:relative;transform:translateY(12px);transition:transform .5s cubic-bezier(.2,.8,.2,1);}
  .modal-wrap.open .modal{transform:translateY(0)}
  .modal h3{font-family:'Fraunces',serif;font-weight:300;font-size:32px;letter-spacing:-0.01em;margin-bottom:6px}
  .modal-sub{font-size:13px;color:var(--ink-dim);margin-bottom:28px;}
  .modal-sub a{color:var(--accent);text-decoration:underline;cursor:pointer}
  .field{margin-bottom:18px}
  .field label{display:block;font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:8px;}
  .field input{width:100%;background:transparent;border:0;border-bottom:1px solid var(--line-strong);color:var(--ink);font-family:'Inter',sans-serif;font-size:15px;padding:10px 0;outline:none;transition:border-color .3s;}
  .field input:focus{border-color:var(--accent)}
  .modal-submit{width:100%;margin-top:14px;background:var(--accent);color:#0a0b0d;border:0;padding:14px;border-radius:999px;font-family:'JetBrains Mono',monospace;font-size:12px;letter-spacing:.15em;text-transform:uppercase;cursor:pointer;transition:filter .3s;}
  .modal-submit:hover{filter:brightness(1.08)}
  .modal-close{position:absolute;top:18px;right:18px;background:transparent;border:0;color:var(--ink-dim);font-size:18px;cursor:pointer;width:32px;height:32px;border-radius:50%;display:grid;place-items:center;transition:background .3s,color .3s;}
  .modal-close:hover{background:var(--line);color:var(--ink)}
  .modal-error{background:rgba(255,107,107,0.1);border:1px solid rgba(255,107,107,0.25);border-radius:8px;padding:10px 14px;font-size:13px;color:var(--danger);margin-bottom:16px;}
  .modal-divider{display:flex;align-items:center;gap:12px;margin:20px 0;font-family:'JetBrains Mono',monospace;font-size:10px;color:var(--ink-dim);letter-spacing:.1em;}
  .modal-divider::before,.modal-divider::after{content:"";flex:1;height:1px;background:var(--line)}

  /* FOOTER */
  footer{position:relative;z-index:1;padding:40px;display:flex;justify-content:space-between;align-items:center;font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;}

  /* REVEAL */
  .reveal{opacity:0;transform:translateY(24px);transition:opacity .9s ease,transform .9s ease}
  .reveal.in{opacity:1;transform:translateY(0)}
  @keyframes pulse{0%,100%{box-shadow:0 0 14px var(--accent);opacity:1}50%{box-shadow:0 0 22px var(--accent);opacity:.6}}
  @media(max-width:700px){.nav{padding:18px 20px}.hero{padding:0 20px 120px}.stat-bar{display:none}h1{font-size:clamp(80px,12vw,120px)}footer{flex-direction:column;gap:12px;padding:30px 20px;text-align:center}}
</style>
</head>
<body>

<nav class="nav">
  <div class="brand">
    <span class="brand-mark"></span>
    <span>NovaEdge <em style="font-style:italic;color:var(--ink-dim)">Academy</em></span>
  </div>
  <div class="nav-actions">
    <button class="btn-ghost" onclick="openLogin()">Sign In</button>
    <a href="register.jsp" class="btn-accent"><span class="dot"></span>Register</a>
  </div>
</nav>

<!-- HERO -->
<section class="hero reveal">
  <div class="ticks"></div>
  <div class="eyebrow">N—01 / Charting the edge of learning</div>
  <h1>A school for the<br/><em>curious</em> &amp; the<br/>quietly ambitious.</h1>
  <% if (loginError != null) { %>
    <div class="error-bar">⚠ <%= loginError %></div>
  <% } %>
  <p class="hero-sub">NovaEdge Academy is a small institution with a wide mind — language, science, code, design, and the human arts of speaking and building.</p>
  <div class="hero-cta">
    <button class="btn-accent" onclick="openLogin()"><span class="dot"></span>Sign In →</button>
    <a href="register.jsp" class="btn-ghost">New student? Register</a>
  </div>

  <div class="stat-bar">
    <div class="stat">EST.<span>2019</span></div>
    <div class="stat">COHORT<span>SPRING / 26</span></div>
    <div class="stat">DISCIPLINES<span>09</span></div>
    <div class="stat">FORMAT<span>HYBRID</span></div>
    <div class="stat">ENROLLMENT<span style="color:var(--accent)">OPEN</span></div>
  </div>
</section>

<footer>
  <div>© NovaEdge Academy — MMXXVI</div>
  <div>Crafted with care · v2.0</div>
</footer>

<!-- LOGIN MODAL -->
<div class="modal-wrap" id="loginModal" onclick="if(event.target===this)closeLogin()">
  <div class="modal">
    <button class="modal-close" onclick="closeLogin()">×</button>
    <h3>Welcome back.</h3>
    <p class="modal-sub">New here? <a href="register.jsp">Create an account</a></p>
    <% if (loginError != null) { %>
      <div class="modal-error">⚠ <%= loginError %></div>
    <% } %>
    <form method="post" action="login">
      <div class="field">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required autocomplete="username"/>
      </div>
      <div class="field">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required autocomplete="current-password"/>
      </div>
      <button type="submit" class="modal-submit">Sign in →</button>
    </form>
  </div>
</div>

<script>
  function openLogin(){ document.getElementById('loginModal').classList.add('open'); }
  function closeLogin(){ document.getElementById('loginModal').classList.remove('open'); }
  document.addEventListener('keydown', e => { if(e.key === 'Escape') closeLogin(); });

  // Auto-open login modal if there was an error
  <% if (loginError != null) { %>
    openLogin();
  <% } %>

  // Reveal on scroll
  const io = new IntersectionObserver(es => es.forEach(e => {
    if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); }
  }), {threshold:.1});
  document.querySelectorAll('.reveal').forEach(el => io.observe(el));
</script>
</body>
</html>
