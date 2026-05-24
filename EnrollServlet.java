package com.novaedge;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/enroll")
public class EnrollServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard: must be logged in
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            resp.sendRedirect("index.jsp");
            return;
        }

        int    studentId  = (int) session.getAttribute("studentId");
        String courseIdStr = req.getParameter("courseId");

        if (courseIdStr == null || courseIdStr.isEmpty()) {
            resp.sendRedirect("courses.jsp");
            return;
        }

        int    courseId   = Integer.parseInt(courseIdStr);
        String courseName = req.getParameter("courseName");

        // ── QUEUE: add request to the queue instead of saving directly ────────
        RegistrationQueue rq = RegistrationQueue.getInstance();

        // Check if already enrolled in the database
        if (DBUtil.isEnrolled(studentId, courseId)) {
            session.setAttribute("toastMsg",
                "You are already enrolled in \"" + courseName + "\".");
            resp.sendRedirect("courses.jsp");
            return;
        }

        // Try to enqueue the request
        boolean queued = rq.enqueue(studentId, courseId);

        if (queued) {
            session.setAttribute("toastMsg",
                "Your enrollment request for \"" + courseName + "\" has been queued. "
                + "It will be confirmed once the admin processes the queue.");
        } else {
            session.setAttribute("toastMsg",
                "Your request for \"" + courseName + "\" is already pending in the queue.");
        }

        resp.sendRedirect("courses.jsp");
    }
}
