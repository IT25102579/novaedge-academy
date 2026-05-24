package com.novaedge;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DBUtil_Queue {

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/novaedge?useSSL=false&serverTimezone=UTC",
            "root", "Sq@67db#24A"
        );
    }

    public static String enroll(int studentId, int courseId) {
        String sql = "INSERT INTO enrollments (student_id, course_id) VALUES (?, ?)";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
            return "ok";

        } catch (SQLIntegrityConstraintViolationException e) {
            return "duplicate";

        } catch (SQLException e) {
            e.printStackTrace();
            return "error";
        }
    }

    public static List<Course> getEnrolledCourses(int studentId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.course_code, c.title, c.description, c.duration "
                   + "FROM courses c "
                   + "JOIN enrollments e ON c.id = e.course_id "
                   + "WHERE e.student_id = ? "
                   + "ORDER BY e.enrolled_at";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();

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

    public static boolean isEnrolled(int studentId, int courseId) {
        String sql = "SELECT id FROM enrollments "
                   + "WHERE student_id = ? AND course_id = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<String[]> getAllEnrollments() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT s.full_name, s.username, c.title, e.enrolled_at "
                   + "FROM enrollments e "
                   + "JOIN students s ON s.id = e.student_id "
                   + "JOIN courses  c ON c.id = e.course_id "
                   + "ORDER BY e.enrolled_at DESC";

        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new String[]{
                    rs.getString("full_name"),
                    rs.getString("username"),
                    rs.getString("title"),
                    rs.getString("enrolled_at")
                });
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
