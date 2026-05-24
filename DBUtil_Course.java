package com.novaedge;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DBUtil_Course {

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/novaedge?useSSL=false&serverTimezone=UTC",
            "root", "your_password_here"
        );
    }

    public static List<Course> getAllCourses() {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT id, course_code, title, description, duration "
                   + "FROM courses ORDER BY id";

        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            // rs.next() moves to next row, returns false when no more rows
            while (rs.next()) {
                list.add(new Course(
                    rs.getInt("id"),
                    rs.getString("course_code"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("duration")
                ));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean addCourse(String code, String title,
                                    String desc, String duration) {
        String sql = "INSERT INTO courses (course_code, title, description, duration) "
                   + "VALUES (?, ?, ?, ?)";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setString(2, title);
            ps.setString(3, desc);
            ps.setString(4, duration);

            // executeUpdate() returns rows affected — 1 means success
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteCourse(int courseId) {
        String sql = "DELETE FROM courses WHERE id = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, courseId);
            // > 0 means at least one row was deleted
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

     public static List<String[]> getAllStudents() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT id, full_name, username, email FROM students WHERE role = 'student' ORDER BY full_name";
        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                    rs.getString("id"),
                    rs.getString("full_name"),
                    rs.getString("username"),
                    rs.getString("email")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public static boolean deleteStudent(int studentId) {
        String delEnroll = "DELETE FROM enrollments WHERE student_id = ?";
        String delStudent = "DELETE FROM students WHERE id = ? AND role = 'student'";
        try (Connection c = getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps1 = c.prepareStatement(delEnroll);
                 PreparedStatement ps2 = c.prepareStatement(delStudent)) {
                ps1.setInt(1, studentId);
                ps1.executeUpdate();
                ps2.setInt(1, studentId);
                boolean ok = ps2.executeUpdate() > 0;
                c.commit();
                return ok;
            } catch (SQLException e) {
                c.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
