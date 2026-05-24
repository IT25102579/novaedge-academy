package com.novaedge;

import java.util.LinkedList;
import java.util.Queue;
import java.util.List;
import java.util.ArrayList;

/**
 * RegistrationQueue — manages pending course enrollment requests.
 *
 * Uses Java's Queue interface (backed by LinkedList) which gives
 * FIFO behaviour: the first request enqueued is the first processed.
 *
 * This is a Singleton — only one queue exists for the whole application,
 * shared across all sessions via a static instance.
 *
 * Each item in the queue is an int[] with two values:
 *   [0] studentId
 *   [1] courseId
 *
 * Human-readable labels (student name, course title) are looked up
 * from the database when displaying the queue on admin.jsp.
 */
public class RegistrationQueue {

   
    // static means one instance is shared across the entire application.
    
    private static final RegistrationQueue INSTANCE = new RegistrationQueue();

   
    private final Queue<int[]> queue = new LinkedList<>();

    // Private constructor
    private RegistrationQueue() {}

    /**
     * Returns the single shared instance of the queue.
     * All servlets call RegistrationQueue.getInstance() to access the same queue.
     */
    public static RegistrationQueue getInstance() {
        return INSTANCE;
    }

    
    //  enqueue() — Person 1's responsibility

    /**
     * Adds a new enrollment request to the back of the queue.
     *
     * @param studentId  the id of the student requesting enrollment
     * @param courseId   the id of the course they want to enroll in
     * @return false if an identical request is already in the queue, true otherwise
     */
    public boolean enqueue(int studentId, int courseId) {
        // Prevent duplicate pending requests for the same student+course pair
        for (int[] request : queue) {
            if (request[0] == studentId && request[1] == courseId) {
                return false; // already queued
            }
        }
        
        queue.add(new int[]{studentId, courseId});
        return true;
    }

    
    //  dequeue() + processAll() — Person 5's responsibility
   

    /**
     * Removes and returns the request at the FRONT of the queue (FIFO).
     * Returns null if the queue is empty.
     */
    public int[] dequeue() {

        return queue.poll();
    }

    /**
     * Processes every request in the queue:
     * dequeues each one and saves it to the database via DBUtil.enroll().
     *
     * @return number of requests successfully saved to the database
     */
    public int processAll() {
        int saved = 0;
        // Keep dequeuing until the queue is empty
        int[] request;
        while ((request = dequeue()) != null) {
            String result = DBUtil.enroll(request[0], request[1]);
            if ("ok".equals(result) || "duplicate".equals(result)) {
                saved++;
            }
        }
        return saved;
    }

    
    //  displayQueue() — Person 2's responsibility
    

    /**
     * Returns a snapshot of all pending requests as a readable list.
     * Each element is a String[] of [studentId, courseId] as strings.
     * Does NOT remove anything from the queue.
     */
    public List<int[]> displayQueue() {
        // Copy queue contents into a plain list for the JSP to iterate over.
       
        return new ArrayList<>(queue);
    }

    /**
     * Returns the number of pending requests currently in the queue.
     */
    public int size() {
        return queue.size();
    }

    /**
     * Returns true if there are no pending requests.
     */
    public boolean isEmpty() {
        return queue.isEmpty();
    }

    
    //  isQueued() — check if a request is already pending
  

    /**
     * Returns true if a pending request for this student+course pair exists.
     * Used by courses.jsp to show the correct badge state.
     */
    public boolean isQueued(int studentId, int courseId) {
        for (int[] request : queue) {
            if (request[0] == studentId && request[1] == courseId) {
                return true;
            }
        }
        return false;
    }
}
