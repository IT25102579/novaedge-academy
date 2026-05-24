<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.novaedge.DBUtil, com.novaedge.Course, com.novaedge.RegistrationQueue" %>
<%
    // Guard: admin only
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) { response.sendRedirect("index.jsp"); return; }

    List<Course>   courses     = DBUtil.getAllCourses();
    List<String[]> enrollments = DBUtil.insertionSortByTime(DBUtil.getAllEnrollments());
    List<String[]> students    = DBUtil.getAllStudents();
    RegistrationQueue rq = RegistrationQueue.getInstance();
    List<int[]> queueItems = rq.displayQueue();

    String adminMsg = (String) session.getAttribute("adminMsg");
    if (adminMsg != null) session.removeAttribute("adminMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Admin — NovaEdge Academy</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,300;9..144,400&family=Inter:wght@300;400;500;600&family=JetBrains+Mono:wght@300;400&display=swap" rel="stylesheet">
<style>
  :root{--bg:#0a0b0d;--bg-2:#101216;--bg-3:#14171c;--ink:#e9eaec;--ink-dim:#8a8f99;--line:rgba(233,234,236,0.10);--line-strong:rgba(233,234,236,0.22);--accent:#7cf0d0;--accent-soft:rgba(124,240,208,0.12);--danger:#ff6b6b;--danger-soft:rgba(255,107,107,0.12);}
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{background:var(--bg);color:var(--ink);font-family:'Inter',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
  a{color:inherit;text-decoration:none}
  ::selection{background:var(--accent);color:#0a0b0d}
  body::before{content:"";position:fixed;inset:0;pointer-events:none;background:radial-gradient(50% 40% at 80% 10%,rgba(124,240,208,0.06),transparent 60%);}

  .nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;align-items:center;padding:22px 40px;backdrop-filter:blur(10px);background:linear-gradient(180deg,rgba(10,11,13,0.85),rgba(10,11,13,0));}
  .brand{display:flex;align-items:center;gap:12px;font-family:'Fraunces',serif;font-weight:400;font-size:18px;letter-spacing:.02em}
  .brand-mark{width:26px;height:26px;border:1px solid var(--ink);border-radius:50%;display:grid;place-items:center;}
  .brand-mark::after{content:"";width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 14px var(--accent);animation:pulse 3s ease-in-out infinite;}
  .admin-badge{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--accent);border:1px solid rgba(124,240,208,0.3);padding:6px 14px;border-radius:999px;}
  .nav-links{display:flex;gap:16px;align-items:center}
  .nav-links a{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--ink-dim);transition:color .3s;}
  .nav-links a:hover{color:var(--ink)}

  .page{position:relative;z-index:1;padding:110px 40px 80px;max-width:1100px;margin:0 auto;}

  /* PAGE HEADER */
  .page-header{padding-bottom:40px;border-bottom:1px solid var(--line);margin-bottom:48px;}
  .page-eyebrow{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--accent);margin-bottom:12px;display:flex;align-items:center;gap:10px;}
  .page-eyebrow::before{content:"";width:16px;height:1px;background:var(--accent)}
  .page-header h1{font-family:'Fraunces',serif;font-weight:300;font-size:clamp(54px,5vw,64px);letter-spacing:-0.02em;}
  .page-header h1 em{font-style:italic;color:var(--ink-dim)}

  /* STATS */
  .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:48px;}
  .stat-card{background:var(--bg-2);border:1px solid var(--line);border-radius:14px;padding:22px 24px;}
  .stat-card .num{font-family:'Fraunces',serif;font-size:42px;font-weight:300;color:var(--accent);line-height:1;}
  .stat-card .label{font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--ink-dim);margin-top:6px;}

  /* TOAST */
  .toast-bar{background:var(--accent-soft);border:1px solid rgba(124,240,208,0.3);border-radius:10px;padding:12px 18px;font-size:13px;color:var(--accent);margin-bottom:28px;display:flex;align-items:center;gap:10px;}

  /* ADD COURSE FORM */
  .section-title{font-family:'Fraunces',serif;font-weight:300;font-size:28px;letter-spacing:-0.01em;margin-bottom:20px;}
  .section-title em{font-style:italic;color:var(--ink-dim)}

  .add-form{background:var(--bg-2);border:1px solid var(--line);border-radius:16px;padding:32px;margin-bottom:48px;}
  .form-grid{display:grid;grid-template-columns:1fr 1fr 2fr 1fr;gap:20px;margin-bottom:20px;}
  .field label{display:block;font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--ink-dim);margin-bottom:8px;}
  .field input{width:100%;background:transparent;border:0;border-bottom:1px solid var(--line-strong);color:var(--ink);font-family:'Inter',sans-serif;font-size:14px;padding:10px 0;outline:none;transition:border-color .3s;}
  .field input:focus{border-color:var(--accent)}
  .field input::placeholder{color:var(--ink-dim);font-size:12px}
  .btn-add{background:var(--accent);color:#0a0b0d;border:0;padding:12px 24px;border-radius:999px;font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.15em;text-transform:uppercase;cursor:pointer;transition:filter .3s;}
  .btn-add:hover{filter:brightness(1.08)}

  /* COURSES TABLE */
  .table-wrap{overflow-x:auto;margin-bottom:48px;}
  table{width:100%;border-collapse:collapse;}
  th{font-family:'JetBrains Mono',monospace;font-size:9px;letter-spacing:.18em;text-transform:uppercase;color:var(--ink-dim);padding:12px 16px;text-align:left;border-bottom:1px solid var(--line-strong);}
  td{padding:16px 16px;border-bottom:1px solid var(--line);font-size:14px;}
  tr:hover td{background:rgba(255,255,255,0.015)}
  .td-code{font-family:'JetBrains Mono',monospace;font-size:11px;letter-spacing:.1em;color:var(--accent)}
  .td-title{font-family:'Fraunces',serif;font-size:20px;font-weight:300}
  .td-desc{font-size:12px;color:var(--ink-dim);font-style:italic}
  .td-dur{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim)}
  .btn-delete{background:var(--danger-soft);border:1px solid rgba(255,107,107,0.25);color:var(--danger);font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.12em;text-transform:uppercase;padding:8px 16px;border-radius:999px;cursor:pointer;transition:all .3s;}
  .btn-delete:hover{background:var(--danger);color:#fff;border-color:var(--danger)}

  /* ENROLLMENTS TABLE */
  .enroll-badge{display:inline-flex;align-items:center;gap:6px;font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--accent);background:var(--accent-soft);padding:4px 12px;border-radius:999px;}

  footer{position:relative;z-index:1;padding:40px;display:flex;justify-content:space-between;align-items:center;font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);letter-spacing:.1em;border-top:1px solid var(--line);}

  @keyframes pulse{0%,100%{box-shadow:0 0 14px var(--accent);opacity:1}50%{box-shadow:0 0 22px var(--accent);opacity:.6}}
  @media(max-width:860px){
    .page{padding:100px 20px 60px}
    .nav{padding:18px 20px}
    .stats-row{grid-template-columns:1fr 1fr}
    .form-grid{grid-template-columns:1fr 1fr}
    footer{flex-direction:column;gap:12px;text-align:center;padding:28px 20px}
  }
</style>
</head>
<body>

<nav class="nav">
  <a href="admin.jsp" class="brand">
    <span class="brand-mark"></span>
    <span>NovaEdge <em style="font-style:italic;color:var(--ink-dim)">Academy</em></span>
  </a>
  <div class="nav-links">
    <span class="admin-badge">Admin Panel</span>
    <a href="courses.jsp">View Courses</a>
    <a href="logout">Sign Out</a>
  </div>
</nav>

<div class="page">

  <div class="page-header">
    <div class="page-eyebrow">Admin</div>
    <h1>Course <em>Management</em></h1>
  </div>

  <!-- STATS -->
  <div class="stats-row" style="grid-template-columns:repeat(4,1fr)">
    <div class="stat-card">
      <div class="num"><%= courses.size() %></div>
      <div class="label">Total Courses</div>
    </div>
    <div class="stat-card">
      <div class="num"><%= students.size() %></div>
      <div class="label">Total Students</div>
    </div>
    <div class="stat-card">
      <div class="num"><%= enrollments.size() %></div>
      <div class="label">Total Enrollments</div>
    </div>
    <div class="stat-card">
      <div class="num" style="font-size:24px;padding-top:8px">Spring<br/>2026</div>
      <div class="label">Active Cohort</div>
    </div>
  </div>

  <!-- MESSAGE -->
  <% if (adminMsg != null) { %>
    <div class="toast-bar">✓ <%= adminMsg %></div>
  <% } %>

  <!-- ADD COURSE -->
  <h3 class="section-title">Add New <em>Course</em></h3>
  <div class="add-form">
    <form method="post" action="admin">
      <input type="hidden" name="action" value="add"/>
      <div class="form-grid">
        <div class="field">
          <label>Course Code</label>
          <input type="text" name="courseCode" placeholder="e.g. PHY-10" required/>
        </div>
        <div class="field">
          <label>Duration</label>
          <input type="text" name="duration" placeholder="e.g. 12 wk" required/>
        </div>
        <div class="field">
          <label>Title</label>
          <input type="text" name="title" placeholder="Course title" required/>
        </div>
        <div class="field">
          <label>Description (short)</label>
          <input type="text" name="description" placeholder="One-line description"/>
        </div>
      </div>
      <button type="submit" class="btn-add">+ Add Course</button>
    </form>
  </div>

  <!-- COURSES TABLE -->
  <h3 class="section-title">All <em>Courses</em></h3>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>Code</th>
          <th>Title</th>
          <th>Description</th>
          <th>Duration</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <% for (Course c : courses) { %>
        <tr>
          <td class="td-code"><%= c.getCourseCode() %></td>
          <td class="td-title"><%= c.getTitle() %></td>
          <td class="td-desc"><%= c.getDescription() %></td>
          <td class="td-dur"><%= c.getDuration() %></td>
          <td>
            <form method="post" action="admin" style="display:inline" onsubmit="return confirm('Delete course "<%= c.getTitle() %>"? All enrollments for this course will also be removed.')">
              <input type="hidden" name="action"     value="delete"/>
              <input type="hidden" name="courseId"   value="<%= c.getId() %>"/>
              <input type="hidden" name="courseName" value="<%= c.getTitle() %>"/>
              <button type="submit" class="btn-delete">Delete</button>
            </form>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>

  <!-- QUEUE SECTION -->
  <h3 class="section-title">Registration <em>Queue</em> (<%= rq.size() %> pending)</h3>
  <% if (queueItems.isEmpty()) { %>
    <div style="border:1px dashed rgba(233,234,236,0.2);border-radius:12px;padding:28px 24px;margin-bottom:40px;color:var(--ink-dim);font-size:14px;font-family:'JetBrains Mono',monospace;">
      No pending requests in the queue.
    </div>
  <% } else { %>
    <div class="table-wrap" style="margin-bottom:24px;">
      <table>
        <thead><tr><th>#</th><th>Student ID</th><th>Course ID</th><th>Status</th></tr></thead>
        <tbody>
          <% int qIdx=1; for (int[] item : queueItems) { %>
          <tr>
            <td class="td-dur"><%= qIdx++ %></td>
            <td class="td-code">Student #<%= item[0] %></td>
            <td class="td-code">Course #<%= item[1] %></td>
            <td><span style="font-family:'JetBrains Mono',monospace;font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:#f0c040;background:rgba(240,192,64,0.1);padding:4px 12px;border-radius:999px;border:1px solid rgba(240,192,64,0.3);">&#9201; Pending</span></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <form method="post" action="admin" onsubmit="return confirm('Process all <%= rq.size() %> queued request(s) and save to database?')">
      <input type="hidden" name="action" value="processQueue"/>
      <button type="submit" class="btn-add" style="background:var(--accent);margin-bottom:48px;">&#9654; Process Queue (<%= rq.size() %> requests)</button>
    </form>
  <% } %>

  <!-- ENROLLMENTS TABLE -->
  <h3 class="section-title">All <em>Enrollments</em> <span style="font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--ink-dim);font-weight:normal;">(sorted by time — insertion sort)</span></h3>
  <div class="table-wrap">
    <% if (enrollments.isEmpty()) { %>
      <p style="color:var(--ink-dim);font-size:14px;padding:20px 0">No enrollments yet.</p>
    <% } else { %>
      <table>
        <thead>
          <tr>
            <th>Student Name</th>
            <th>Username</th>
            <th>Course</th>
            <th>Enrolled At</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <% for (String[] e : enrollments) { %>
          <tr>
            <td><%= e[0] %></td>
            <td class="td-code">@<%= e[1] %></td>
            <td class="td-title" style="font-size:16px"><%= e[2] %></td>
            <td class="td-dur"><%= e[3] %></td>
            <td><span class="enroll-badge">✓ Active</span></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    <% } %>
  </div>

  <!-- STUDENTS TABLE -->
  <h3 class="section-title">All <em>Students</em></h3>
  <div class="table-wrap">
    <% if (students.isEmpty()) { %>
      <p style="color:var(--ink-dim);font-size:14px;padding:20px 0">No students registered yet.</p>
    <% } else { %>
      <table>
        <thead>
          <tr>
            <th>Full Name</th>
            <th>Username</th>
            <th>Email</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% for (String[] s : students) { %>
          <tr>
            <td><%= s[1] %></td>
            <td class="td-code">@<%= s[2] %></td>
            <td class="td-dur"><%= s[3] %></td>
            <td>
              <form method="post" action="admin" style="display:inline"
                    onsubmit="return confirm('Remove student \"<%= s[1] %>\"? This will also delete all their enrollments.')">
                <input type="hidden" name="action"      value="deleteStudent"/>
                <input type="hidden" name="studentId"   value="<%= s[0] %>"/>
                <input type="hidden" name="studentName" value="<%= s[1] %>"/>
                <button type="submit" class="btn-delete">Remove</button>
              </form>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    <% } %>
  </div>

</div>

<footer>
  <div>© NovaEdge Academy — MMXXVI</div>
  <div>Admin Panel</div>
</footer>


</body>
</html>
