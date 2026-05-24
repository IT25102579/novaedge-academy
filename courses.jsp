<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.novaedge.DBUtil, com.novaedge.Course, com.novaedge.RegistrationQueue" %>
<%
    // Guard: must be logged in
    Integer studentId = (Integer) session.getAttribute("studentId");
    if (studentId == null) { response.sendRedirect("index.jsp"); return; }

    String studentName = (String) session.getAttribute("studentName");
    String role        = (String) session.getAttribute("role");

    // Fetch courses and enrolled course IDs
    List<Course> courses = DBUtil.getAllCourses();
    List<Course> enrolled = DBUtil.getEnrolledCourses(studentId);
    java.util.Set<Integer> enrolledIds = new java.util.HashSet<>();
    for (Course c : enrolled) enrolledIds.add(c.getId());

    // Queue — check which courses have a pending request
    RegistrationQueue rq = RegistrationQueue.getInstance();

    // Toast from session
    String toastMsg  = (String) session.getAttribute("toastMsg");
    String regSuccess = (String) session.getAttribute("regSuccess");
    if (toastMsg   != null) session.removeAttribute("toastMsg");
    if (regSuccess != null) session.removeAttribute("regSuccess");
    String toast = regSuccess != null ? regSuccess : toastMsg;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Courses — NovaEdge Academy</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,300;9..144,400&family=Inter:wght@300;400;500;600&family=JetBrains+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
  :root{--bg:#0a0b0d;--bg-2:#101216;--ink:#e9eaec;--ink-dim:#8a8f99;--line:rgba(233,234,236,0.10);--line-strong:rgba(233,234,236,0.22);--accent:#7cf0d0;--accent-soft:rgba(124,240,208,0.12);}
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{background:var(--bg);color:var(--ink);font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
  a{color:inherit;text-decoration:none}
  ::selection{background:var(--accent);color:#0a0b0d}
  body::before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;background:radial-gradient(60% 40% at 20% 10%,rgba(124,240,208,0.08),transparent 60%),radial-gradient(50% 50% at 90% 90%,rgba(120,90,255,0.06),transparent 60%);}

  /* NAV */
  .nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;align-items:center;padding:22px 40px;backdrop-filter:blur(10px);background:linear-gradient(180deg,rgba(10,11,13,0.85),rgba(10,11,13,0));}
  .brand{display:flex;align-items:center;gap:12px;font-family:'Fraunces',serif;font-weight:400;font-size:18px;letter-spacing:.02em}
  .brand-mark{width:26px;height:26px;border:1px solid var(--ink);border-radius:50%;display:grid;place-items:center;}
  .brand-mark::after{content:"";width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 14px var(--accent);animation:pulse 3s ease-in-out infinite;}
  .nav-links{display:flex;gap:16px;align-items:center;font-size:13px;}
  .nav-links a, .nav-links button{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--ink-dim);background:transparent;border:none;cursor:pointer;padding:0;transition:color .3s;}
  .nav-links a:hover, .nav-links button:hover{color:var(--ink)}
  .user-chip{display:flex;align-items:center;gap:8px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--accent);border:1px solid rgba(124,240,208,0.25);padding:8px 16px;border-radius:999px;}
  .user-chip .dot{width:6px;height:6px;border-radius:50%;background:var(--accent);box-shadow:0 0 8px var(--accent)}

  /* HERO */
  .hero{position:relative;z-index:1;padding:160px 40px 60px;border-bottom:1px solid var(--line);display:grid;grid-template-columns:1.2fr .8fr;gap:60px;align-items:end;}
  .eyebrow{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.18em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:24px;display:flex;align-items:center;gap:10px;}
  .eyebrow::before{content:"";width:24px;height:1px;background:var(--accent)}
  h1{font-family:'Fraunces',serif;font-weight:300;font-size:clamp(64px,6vw,88px);line-height:.95;letter-spacing:-0.02em;}
  h1 em{font-style:italic;color:var(--accent);font-weight:300}
  .hero-meta{border-left:1px solid var(--line);padding-left:28px;font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);line-height:1.9;letter-spacing:.05em;}
  .hero-meta span{color:var(--ink)}
  .ticks{position:absolute;inset:120px 40px 40px;pointer-events:none;}
  .ticks::before,.ticks::after{content:"";position:absolute;width:14px;height:14px;border:1px solid var(--line-strong);}
  .ticks::before{top:0;left:0;border-right:0;border-bottom:0}
  .ticks::after{bottom:0;right:0;border-left:0;border-top:0}

  /* COURSES */
  .section-head{display:flex;justify-content:space-between;align-items:flex-end;padding:60px 40px 28px;border-bottom:1px solid var(--line);}
  .section-head h2{font-family:'Fraunces',serif;font-weight:300;font-size:clamp(44px,4vw,52px);letter-spacing:-0.02em;line-height:1;}
  .section-head .meta{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;text-transform:uppercase;text-align:right;line-height:1.8;}

  .course{display:grid;grid-template-columns:80px 1fr 2fr 100px 200px;align-items:center;gap:24px;padding:28px 40px;border-bottom:1px solid var(--line);transition:background .4s ease,padding-left .4s ease;position:relative;overflow:hidden;}
  .course::before{content:"";position:absolute;left:0;top:0;bottom:0;width:2px;background:var(--accent);transform:scaleY(0);transform-origin:top;transition:transform .5s ease;}
  .course:hover{background:rgba(255,255,255,0.015);padding-left:56px}
  .course:hover::before{transform:scaleY(1)}
  .course-num{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em}
  .course-title{font-family:'Fraunces',serif;font-size:26px;font-weight:300;letter-spacing:-0.01em}
  .course-desc{font-size:13px;color:var(--ink-dim);font-style:italic;font-family:'Fraunces',serif}
  .course-dur{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;text-transform:uppercase}
  .enroll-area{justify-self:end}

  .enroll-btn{background:transparent;border:1px solid var(--line-strong);color:var(--ink);font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.15em;text-transform:uppercase;padding:12px 20px;border-radius:999px;cursor:pointer;display:inline-flex;align-items:center;gap:10px;transition:all .35s ease;}
  .enroll-btn .arrow{transition:transform .35s ease}
  .enroll-btn:hover{background:var(--ink);color:#0a0b0d;border-color:var(--ink)}
  .enroll-btn:hover .arrow{transform:translateX(4px)}

  .enrolled-badge{display:inline-flex;align-items:center;gap:8px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);padding:12px 20px;border-radius:999px;border:1px solid rgba(124,240,208,0.3);background:var(--accent-soft);}
  .pending-badge{display:inline-flex;align-items:center;gap:8px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:#f0c040;padding:12px 20px;border-radius:999px;border:1px solid rgba(240,192,64,0.4);background:rgba(240,192,64,0.10);}

  /* TOAST */
  .toast{position:fixed;bottom:32px;left:50%;transform:translateX(-50%) translateY(20px);background:var(--ink);color:#0a0b0d;padding:14px 24px;border-radius:999px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.12em;text-transform:uppercase;z-index:200;opacity:0;transition:all .5s cubic-bezier(.2,.8,.2,1);white-space:nowrap;}
  .toast.show{opacity:1;transform:translateX(-50%) translateY(0)}

  footer{position:relative;z-index:1;padding:60px 40px 32px;display:flex;justify-content:space-between;align-items:center;font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;}

  .reveal{opacity:0;transform:translateY(24px);transition:opacity .9s ease,transform .9s ease}
  .reveal.in{opacity:1;transform:translateY(0)}
  @keyframes pulse{0%,100%{box-shadow:0 0 14px var(--accent);opacity:1}50%{box-shadow:0 0 22px var(--accent);opacity:.6}}

  @media(max-width:860px){
    .nav{padding:18px 20px}
    .hero{grid-template-columns:1fr;padding:130px 20px 48px;gap:32px}
    .ticks{display:none}
    .section-head{padding:48px 20px 20px;flex-direction:column;align-items:flex-start;gap:12px}
    .course{grid-template-columns:44px 1fr;grid-template-areas:"num title" ". desc" ". dur" ". enroll";gap:6px 14px;padding:22px 20px}
    .course:hover{padding-left:32px}
    .course-num{grid-area:num;align-self:start;padding-top:5px}
    .course-title{grid-area:title;font-size:21px}
    .course-desc{grid-area:desc;grid-column:2}
    .course-dur{grid-area:dur;grid-column:2}
    .enroll-area{grid-area:enroll;grid-column:2;justify-self:start;margin-top:6px}
    footer{flex-direction:column;gap:12px;text-align:center;padding:36px 20px}
  }
</style>
</head>
<body>

<nav class="nav">
  <a href="courses.jsp" class="brand">
    <span class="brand-mark"></span>
    <span>NovaEdge <em style="font-style:italic;color:var(--ink-dim)">Academy</em></span>
  </a>
  <div class="nav-links">
    <a href="profile.jsp">My Profile</a>
    <% if ("admin".equals(role)) { %><a href="admin.jsp">Admin</a><% } %>
    <a href="logout">Sign Out</a>
    <div class="user-chip"><span class="dot"></span><%= studentName %></div>
  </div>
</nav>

<!-- HERO -->
<section class="hero reveal">
  <div class="ticks"></div>
  <div>
    <div class="eyebrow">N—01 / Spring Cohort 2026</div>
    <h1>The <em>Curriculum</em></h1>
  </div>
  <aside class="hero-meta">
    <div>STUDENT <span><%= studentName %></span></div>
    <div>COHORT <span>SPRING / 26</span></div>
    <div>ENROLLED <span style="color:var(--accent)"><%= enrolled.size() %> / <%= courses.size() %></span></div>
    <div>FORMAT <span>HYBRID</span></div>
  </aside>
</section>

<!-- COURSE LIST -->
<section>
  <div class="section-head reveal">
    <h2>Available <em style="font-style:italic;color:var(--ink-dim)">Courses</em></h2>
    <div class="meta">
      <div><%= courses.size() %> disciplines</div>
      <div>Updated · Spring 26</div>
    </div>
  </div>

  <% int idx = 1;
     for (Course c : courses) {
       boolean isEnrolled = enrolledIds.contains(c.getId());
       boolean isPending  = rq.isQueued(studentId, c.getId());
  %>
  <article class="course reveal">
    <div class="course-num"><%= String.format("%02d", idx++) %></div>
    <div class="course-title"><%= c.getTitle() %></div>
    <div class="course-desc"><%= c.getDescription() %></div>
    <div class="course-dur"><%= c.getDuration() %></div>
    <div class="enroll-area">
      <% if (isEnrolled) { %>
        <span class="enrolled-badge">&#10003; Enrolled</span>
      <% } else if (isPending) { %>
        <span class="pending-badge">&#9201; Pending</span>
      <% } else { %>
        <form method="post" action="enroll" style="display:inline">
          <input type="hidden" name="courseId"   value="<%= c.getId() %>"/>
          <input type="hidden" name="courseName" value="<%= c.getTitle() %>"/>
          <button type="submit" class="enroll-btn">Enroll <span class="arrow">&#8594;</span></button>
        </form>
      <% } %>
    </div>
  </article>
  <% } %>
</section>

<footer>
  <div>© NovaEdge Academy — MMXXVI</div>
  <div>Crafted with care · v2.0</div>
</footer>

<div class="toast" id="toast"></div>

<script>
  function showToast(msg) {
    const t = document.getElementById('toast');
    t.textContent = msg; t.classList.add('show');
    clearTimeout(window.__tt);
    window.__tt = setTimeout(() => t.classList.remove('show'), 2800);
  }
  <% if (toast != null) { %>
    showToast("<%= toast.replace("\"","\\\"") %>");
  <% } %>

  const io = new IntersectionObserver(es => es.forEach(e => {
    if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); }
  }), {threshold:.08});
  document.querySelectorAll('.reveal').forEach(el => io.observe(el));
</script>
</body>
</html>
