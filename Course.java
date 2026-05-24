package com.novaedge;

public class Course {
    private int    id;
    private String courseCode;
    private String title;
    private String description;
    private String duration;

    //public Course() {}

    public Course(int id, String courseCode, String title,
                  String description, String duration) {
        this.id          = id;
        this.courseCode  = courseCode;
        this.title       = title;
        this.description = description;
        this.duration    = duration;
    }

    // ── Getters ──────────────────────────────────────────────
    public int    getId()          { return id; }
    public String getCourseCode()  { return courseCode; }
    public String getTitle()       { return title; }
    public String getDescription() { return description; }
    public String getDuration()    { return duration; }

    // ── Setters ──────────────────────────────────────────────
    public void setId(int id)              { this.id = id; }
    public void setCourseCode(String c)    { this.courseCode = c; }
    public void setTitle(String t)         { this.title = t; }
    public void setDescription(String d)   { this.description = d; }
    public void setDuration(String dur)    { this.duration = dur; }
}
