<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.novaedge.DBUtil, com.novaedge.Course, com.novaedge.Student" %>
<%
    Integer studentId = (Integer) session.getAttribute("studentId");
    if (studentId == null) { response.sendRedirect("index.jsp"); return; }

    Student student = (Student) session.getAttribute("student");
    List<Course> allCourses    = DBUtil.getAllCourses();
    List<Course> enrolled      = DBUtil.getEnrolledCourses(studentId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>My Profile — NovaEdge Academy</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,300;9..144,400&family=Inter:wght@300;400;500;600&family=JetBrains+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
  :root{--bg:#0a0b0d;--bg-2:#101216;--bg-3:#14171c;--ink:#e9eaec;--ink-dim:#8a8f99;--line:rgba(233,234,236,0.10);--line-strong:rgba(233,234,236,0.22);--accent:#7cf0d0;--accent-soft:rgba(124,240,208,0.12);}
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{background:var(--bg);color:var(--ink);font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
  a{color:inherit;text-decoration:none}
  ::selection{background:var(--accent);color:#0a0b0d}
  body::before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;background:radial-gradient(40% 40% at 70% 20%,rgba(124,240,208,0.07),transparent 60%);}

  .nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;align-items:center;padding:22px 40px;backdrop-filter:blur(10px);background:linear-gradient(180deg,rgba(10,11,13,0.85),rgba(10,11,13,0));}
  .brand{display:flex;align-items:center;gap:12px;font-family:'Fraunces',serif;font-weight:400;font-size:18px;letter-spacing:.02em}
  .brand-mark{width:26px;height:26px;border:1px solid var(--ink);border-radius:50%;display:grid;place-items:center;}
  .brand-mark::after{content:"";width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 14px var(--accent);animation:pulse 3s ease-in-out infinite;}
  .nav-links{display:flex;gap:16px;align-items:center}
  .nav-links a, .nav-links button{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--ink-dim);background:transparent;border:none;cursor:pointer;padding:0;transition:color .3s;}
  .nav-links a:hover,.nav-links button:hover{color:var(--ink)}

  .page{position:relative;z-index:1;padding:120px 40px 80px;max-width:1100px;margin:0 auto;}

  /* PROFILE HEADER */
  .profile-header{display:flex;align-items:flex-start;gap:40px;padding-bottom:48px;border-bottom:1px solid var(--line);margin-bottom:48px;}
  .avatar{width:80px;height:80px;border-radius:50%;background:var(--accent-soft);border:1px solid rgba(124,240,208,0.3);display:flex;align-items:center;justify-content:center;font-family:'Fraunces',serif;font-size:32px;font-weight:300;color:var(--accent);flex-shrink:0;}
  .profile-info h2{font-family:'Fraunces',serif;font-weight:300;font-size:38px;letter-spacing:-0.01em;margin-bottom:6px;}
  .profile-badge{display:inline-flex;align-items:center;gap:6px;font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--accent);border:1px solid rgba(124,240,208,0.3);padding:5px 12px;border-radius:999px;margin-bottom:16px;}
  .profile-fields{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-top:16px;}
  .pfield{background:var(--bg-2);border:1px solid var(--line);border-radius:12px;padding:14px 18px;}
  .pfield-label{font-family:'JetBrains Mono',monospace;font-size:9px;letter-spacing:.18em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:5px;}
  .pfield-val{font-size:14px;color:var(--ink)}

  /* STATS */
  .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:48px;}
  .stat-card{background:var(--bg-2);border:1px solid var(--line);border-radius:14px;padding:22px 24px;}
  .stat-card .num{font-family:'Fraunces',serif;font-size:40px;font-weight:300;color:var(--accent);line-height:1;}
  .stat-card .label{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--ink-dim);margin-top:6px;}

  /* ENROLLED COURSES */
  .section-title{font-family:'Fraunces',serif;font-weight:300;font-size:clamp(26px,3vw,38px);letter-spacing:-0.01em;margin-bottom:24px;}
  .section-title em{font-style:italic;color:var(--ink-dim)}

  .enrolled-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;margin-bottom:56px;}
  .course-card{background:var(--bg-2);border:1px solid var(--line);border-radius:14px;padding:24px;transition:border-color .3s,background .3s;position:relative;overflow:hidden;}
  .course-card::before{content:"";position:absolute;left:0;top:0;bottom:0;width:2px;background:var(--accent);}
  .course-card:hover{border-color:rgba(124,240,208,0.25);background:var(--bg-3)}
  .cc-code{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--accent);margin-bottom:8px;}
  .cc-title{font-family:'Fraunces',serif;font-size:22px;font-weight:300;margin-bottom:6px;}
  .cc-desc{font-size:12px;color:var(--ink-dim);font-style:italic;margin-bottom:12px;}
  .cc-dur{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--ink-dim);}
  .cc-badge{position:absolute;top:18px;right:18px;font-family:'JetBrains Mono',monospace;font-size:9px;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);background:var(--accent-soft);padding:4px 10px;border-radius:999px;}

  .empty-state{text-align:center;padding:60px 24px;border:1px dashed var(--line-strong);border-radius:16px;margin-bottom:40px;}
  .empty-state .emoji{font-size:40px;margin-bottom:16px;}
  .empty-state p{color:var(--ink-dim);font-size:14px;margin-bottom:20px;}
  .btn-accent{background:var(--accent);color:#0a0b0d;border:0;padding:12px 24px;border-radius:999px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.15em;text-transform:uppercase;cursor:pointer;text-decoration:none;display:inline-block;transition:filter .3s;}
  .btn-accent:hover{filter:brightness(1.08)}

  footer{position:relative;z-index:1;padding:40px;display:flex;justify-content:space-between;align-items:center;font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;border-top:1px solid var(--line);}

  .reveal{opacity:0;transform:translateY(20px);transition:opacity .8s ease,transform .8s ease}
  .reveal.in{opacity:1;transform:translateY(0)}
  @keyframes pulse{0%,100%{box-shadow:0 0 14px var(--accent);opacity:1}50%{box-shadow:0 0 22px var(--accent);opacity:.6}}

  @media(max-width:760px){
    .page{padding:100px 20px 60px}
    .profile-header{flex-direction:column;gap:20px}
    .profile-fields{grid-template-columns:1fr 1fr}
    .stats-row{grid-template-columns:1fr 1fr}
    .enrolled-grid{grid-template-columns:1fr}
    .nav{padding:18px 20px}
    footer{flex-direction:column;gap:12px;text-align:center;padding:30px 20px}
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
    <a href="courses.jsp">Courses</a>
    <a href="logout">Sign Out</a>
  </div>
</nav>

<div class="page">

  <!-- PROFILE HEADER -->
  <div class="profile-header reveal">
    <div class="avatar"><%= student.getFullName().substring(0,1).toUpperCase() %></div>
    <div class="profile-info">
      <div class="profile-badge">◉ Student</div>
      <h2><%= student.getFullName() %></h2>
      <div class="profile-fields">
        <div class="pfield">
          <div class="pfield-label">Username</div>
          <div class="pfield-val">@<%= student.getUsername() %></div>
        </div>
        <div class="pfield">
          <div class="pfield-label">Email</div>
          <div class="pfield-val"><%= student.getEmail() %></div>
        </div>
        <div class="pfield">
          <div class="pfield-label">Phone</div>
          <div class="pfield-val"><%= student.getPhone() != null && !student.getPhone().isEmpty() ? student.getPhone() : "—" %></div>
        </div>
      </div>
    </div>
  </div>

  <!-- STATS -->
  <div class="stats-row reveal">
    <div class="stat-card">
      <div class="num"><%= enrolled.size() %></div>
      <div class="label">Courses Enrolled</div>
    </div>
    <div class="stat-card">
      <div class="num"><%= allCourses.size() - enrolled.size() %></div>
      <div class="label">Available to Enroll</div>
    </div>
    <div class="stat-card">
      <div class="num" style="font-size:24px;padding-top:8px">Spring<br/>2026</div>
      <div class="label">Current Cohort</div>
    </div>
  </div>

  <!-- ENROLLED COURSES -->
  <h3 class="section-title reveal">My <em>Enrolled</em> Courses</h3>

  <% if (enrolled.isEmpty()) { %>
    <div class="empty-state reveal">
      <div class="emoji">📚</div>
      <p>You have not enrolled in any courses yet.</p>
      <a href="courses.jsp" class="btn-accent">Browse Courses →</a>
    </div>
  <% } else { %>
    <div class="enrolled-grid">
      <% for (Course c : enrolled) { %>
        <div class="course-card reveal">
          <span class="cc-badge">✓ Enrolled</span>
          <div class="cc-code"><%= c.getCourseCode() %></div>
          <div class="cc-title"><%= c.getTitle() %></div>
          <div class="cc-desc"><%= c.getDescription() %></div>
          <div class="cc-dur"><%= c.getDuration() %></div>
        </div>
      <% } %>
    </div>
    <a href="courses.jsp" class="btn-accent reveal">Browse More Courses →</a>
  <% } %>

</div>

<footer>
  <div>© NovaEdge Academy — MMXXVI</div>
  <div>Your profile</div>
</footer>

<script>
  const io = new IntersectionObserver(es => es.forEach(e => {
    if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); }
  }), {threshold:.08});
  document.querySelectorAll('.reveal').forEach(el => io.observe(el));
</script>
</body>
</html>
