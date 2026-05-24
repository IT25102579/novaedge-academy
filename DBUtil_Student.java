package com.novaedge;

import java.sql.*;

public class DBUtil_Student {

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/novaedge?useSSL=false&serverTimezone=UTC",
            "root", "1234"
        );
    }

       public static boolean usernameExists(String username) {
        String sql = "SELECT id FROM students WHERE username = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, username);
            
            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean emailExists(String email) {
        String sql = "SELECT id FROM students WHERE email = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, email);
            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static Student register(String fullName, String email, String phone,
                                   String username, String password) {

        String sql = "INSERT INTO students (full_name, email, phone, username, password, role) "
                   + "VALUES (?, ?, ?, ?, ?, 'student')";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, username);
            ps.setString(5, password);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int newId = keys.getInt(1);
                return new Student(newId, fullName, email, phone,
                                   username, password, "student");
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
}
