package com.novaedge;

public class Student {
    private int    id;
    private String fullName;
    private String email;
    private String phone;
    private String username;
    private String password;
    private String role;

    public Student() {}

    public Student(int id, String fullName, String email, String phone,
                   String username, String password, String role) {
        this.id       = id;
        this.fullName = fullName;
        this.email    = email;
        this.phone    = phone;
        this.username = username;
        this.password = password;
        this.role     = role;
    }

    // ── Getters ──────────────────────────────────────────────
    public int    getId()       { return id; }
    public String getFullName() { return fullName; }
    public String getEmail()    { return email; }
    public String getPhone()    { return phone; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getRole()     { return role; }

    // ── Setters ──────────────────────────────────────────────
    public void setId(int id)             { this.id = id; }
    public void setFullName(String n)     { this.fullName = n; }
    public void setEmail(String e)        { this.email = e; }
    public void setPhone(String p)        { this.phone = p; }
    public void setUsername(String u)     { this.username = u; }
    public void setPassword(String p)     { this.password = p; }
    public void setRole(String r)         { this.role = r; }
}
