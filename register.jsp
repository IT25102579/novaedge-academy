<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("role") != null) { response.sendRedirect("courses.jsp"); return; }
    String regError = (String) session.getAttribute("regError");
    if (regError != null) session.removeAttribute("regError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Register — NovaEdge Academy</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,300;9..144,400&family=Inter:wght@300;400;500;600&family=JetBrains+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
  :root{--bg:#0a0b0d;--bg-2:#101216;--ink:#e9eaec;--ink-dim:#8a8f99;--line:rgba(233,234,236,0.10);--line-strong:rgba(233,234,236,0.22);--accent:#7cf0d0;--danger:#ff6b6b;}
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{background:var(--bg);color:var(--ink);font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;min-height:100vh;}
  ::selection{background:var(--accent);color:#0a0b0d}
  body::before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;background:radial-gradient(60% 40% at 80% 20%,rgba(124,240,208,0.07),transparent 60%),radial-gradient(40% 50% at 10% 80%,rgba(120,90,255,0.05),transparent 60%);}

  .nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;align-items:center;padding:22px 40px;backdrop-filter:blur(10px);background:linear-gradient(180deg,rgba(10,11,13,0.85),rgba(10,11,13,0));}
  .brand{display:flex;align-items:center;gap:12px;font-family:'Fraunces',serif;font-weight:400;font-size:18px;letter-spacing:.02em}
  .brand-mark{width:26px;height:26px;border:1px solid var(--ink);border-radius:50%;display:grid;place-items:center;}
  .brand-mark::after{content:"";width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 14px var(--accent);animation:pulse 3s ease-in-out infinite;}
  .back-link{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.12em;color:var(--ink-dim);text-decoration:none;display:flex;align-items:center;gap:8px;transition:color .3s;}
  .back-link:hover{color:var(--ink)}

  .page{position:relative;z-index:1;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:100px 24px 60px;}
  .card{background:var(--bg-2);border:1px solid var(--line-strong);border-radius:20px;width:100%;max-width:520px;padding:48px;}
  .card-eyebrow{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--accent);margin-bottom:14px;display:flex;align-items:center;gap:10px;}
  .card-eyebrow::before{content:"";width:16px;height:1px;background:var(--accent)}
  .card h2{font-family:'Fraunces',serif;font-weight:300;font-size:38px;letter-spacing:-0.01em;margin-bottom:8px;}
  .card-sub{font-size:13px;color:var(--ink-dim);margin-bottom:32px;}
  .card-sub a{color:var(--accent);text-decoration:underline}

  .error-box{background:rgba(255,107,107,0.1);border:1px solid rgba(255,107,107,0.25);border-radius:10px;padding:12px 16px;font-size:13px;color:var(--danger);margin-bottom:20px;display:flex;align-items:center;gap:10px;}

  .row-2{display:grid;grid-template-columns:1fr 1fr;gap:0 20px;}
  .field{margin-bottom:22px}
  .field label{display:block;font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:8px;}
  .field input{width:100%;background:transparent;border:0;border-bottom:1px solid var(--line-strong);color:var(--ink);font-family:'Inter',sans-serif;font-size:15px;padding:10px 0;outline:none;transition:border-color .3s;}
  .field input:focus{border-color:var(--accent)}
  .field input::placeholder{color:var(--ink-dim);font-size:13px}

  .submit-btn{width:100%;margin-top:8px;background:var(--accent);color:#0a0b0d;border:0;padding:15px;border-radius:999px;font-family:'JetBrains Mono',monospace;font-size:12px;letter-spacing:.15em;text-transform:uppercase;cursor:pointer;transition:filter .3s;}
  .submit-btn:hover{filter:brightness(1.08)}

  .divider{display:flex;align-items:center;gap:12px;margin:24px 0 20px;font-family:'JetBrains Mono',monospace;font-size:10px;color:var(--ink-dim);letter-spacing:.1em;}
  .divider::before,.divider::after{content:"";flex:1;height:1px;background:var(--line)}

  .signin-link{display:block;text-align:center;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--ink-dim);text-decoration:none;padding:14px;border-radius:999px;border:1px solid var(--line-strong);transition:all .3s;}
  .signin-link:hover{border-color:var(--ink);color:var(--ink)}

  .strength{height:2px;border-radius:2px;margin-top:6px;transition:all .3s;background:var(--line)}
  .strength.weak{background:var(--danger);width:33%}
  .strength.ok{background:#f0c040;width:66%}
  .strength.strong{background:var(--accent);width:100%}

  @keyframes pulse{0%,100%{box-shadow:0 0 14px var(--accent);opacity:1}50%{box-shadow:0 0 22px var(--accent);opacity:.6}}
  @media(max-width:580px){.card{padding:32px 24px}.row-2{grid-template-columns:1fr}.nav{padding:18px 20px}}
</style>
</head>
<body>

<nav class="nav">
  <a href="index.jsp" class="brand">
    <span class="brand-mark"></span>
    <span>NovaEdge <em style="font-style:italic;color:var(--ink-dim)">Academy</em></span>
  </a>
  <a href="index.jsp" class="back-link">← Back to home</a>
</nav>

<div class="page">
  <div class="card">
    <div class="card-eyebrow">New Student</div>
    <h2>Create your account.</h2>
    <p class="card-sub">Already have an account? <a href="index.jsp">Sign in here</a></p>

    <% if (regError != null) { %>
      <div class="error-box">⚠ <%= regError %></div>
    <% } %>

    <form method="post" action="register">
      <div class="row-2">
        <div class="field">
          <label>Full Name</label>
          <input type="text" name="fullName" placeholder="Jane Smith" required/>
        </div>
        <div class="field">
          <label>Phone (optional)</label>
          <input type="tel" name="phone" placeholder="+94 77 000 0000"/>
        </div>
      </div>

      <div class="field">
        <label>Email Address</label>
        <input type="email" name="email" placeholder="jane@example.com" required/>
      </div>

      <div class="field">
        <label>Username</label>
        <input type="text" name="username" placeholder="jane_smith" required autocomplete="username" pattern="[a-zA-Z0-9_]{3,}" title="At least 3 characters; letters, numbers and underscore only"/>
      </div>

      <div class="row-2">
        <div class="field">
          <label>Password</label>
          <input type="password" name="password" id="pwd" placeholder="Min. 6 characters" required minlength="6" oninput="checkStrength(this.value)"/>
          <div class="strength" id="strengthBar"></div>
        </div>
        <div class="field">
          <label>Confirm Password</label>
          <input type="password" name="confirmPassword" placeholder="Repeat password" required minlength="6"/>
        </div>
      </div>

      <button type="submit" class="submit-btn">Create account →</button>
    </form>

    <div class="divider">OR</div>
    <a href="index.jsp" class="signin-link">Sign in to existing account</a>
  </div>
</div>

<script>
  function checkStrength(v) {
    const bar = document.getElementById('strengthBar');
    if (v.length < 4)      { bar.className = 'strength weak'; }
    else if (v.length < 8) { bar.className = 'strength ok'; }
    else                   { bar.className = 'strength strong'; }
  }
</script>
</body>
</html>
