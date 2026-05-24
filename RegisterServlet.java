package com.novaedge;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class   RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fullName  = req.getParameter("fullName").trim();
        String email     = req.getParameter("email").trim();
        String phone     = req.getParameter("phone").trim();
        String username  = req.getParameter("username").trim();
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirmPassword");

        // ── Validation ─────────────────────────────────────────────
        if (!password.equals(confirm)) {
            req.getSession().setAttribute("regError", "Passwords do not match.");
            resp.sendRedirect("register.jsp");
            return;
        }
        if (DBUtil.usernameExists(username)) {
            req.getSession().setAttribute("regError", "Username \"" + username + "\" is already taken.");
            resp.sendRedirect("register.jsp");
            return;
        }
        if (DBUtil.emailExists(email)) {
            req.getSession().setAttribute("regError", "An account with that email already exists.");
            resp.sendRedirect("register.jsp");
            return;
        }

        // ── Create account ─────────────────────────────────────────
        Student student = DBUtil.register(fullName, email, phone, username, password);

        if (student != null) {
            // Log them in immediately
            HttpSession session = req.getSession();
            session.setAttribute("student",     student);
            session.setAttribute("studentId",   student.getId());
            session.setAttribute("studentName", student.getFullName());
            session.setAttribute("role",        student.getRole());
            session.setAttribute("regSuccess",  "Welcome, " + student.getFullName() + "! You are now registered.");
            resp.sendRedirect("courses.jsp");
        } else {
            req.getSession().setAttribute("regError", "Registration failed. Please try again.");
            resp.sendRedirect("register.jsp");
        }
    }
}
