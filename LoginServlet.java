package com.novaedge;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        Student student = DBUtil.login(username, password);

        if (student != null) {
            // Store student in session
            HttpSession session = req.getSession();
            session.setAttribute("student", student);
            session.setAttribute("studentId",   student.getId());
            session.setAttribute("studentName", student.getFullName());
            session.setAttribute("role",        student.getRole());

            if ("admin".equals(student.getRole())) {
                resp.sendRedirect("admin.jsp");
            } else {

                 resp.sendRedirect("courses.jsp");
            }
        } else {
            // Wrong credentials → back to home with error
            req.getSession().setAttribute("loginError", "Invalid username or password. Please try again.");
            resp.sendRedirect("index.jsp?error=1");
        }
    }
}
