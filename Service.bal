// Service.bal

import ballerina/http;
import ballerina/io;

// In-memory data store for lecturers
    map<json> lecturersData = {};  // Defines the map at the service level

service /faculty on new http:Listener(9090) {

    // Resource to retrieve all lecturers
    resource function get getAllLecturers(http:Request req, http:Response res) {
        json[] lecturers = [];
        string[] staffNumbers = lecturersData.keys();
        foreach string staffNumber in staffNumbers {
            json? lecturer = lecturersData[staffNumber];
            if (lecturer != null) {
                lecturers.push(lecturer);
            }
        }
        res.setJsonPayload(lecturers);
        _ = res.flush();
    }

    // Resource to add a new lecturer
    resource function post addLecturer(http:Request req, http:Response res) {
        json lecturer = check req.getJsonPayload();
        string staffNumber = check lecturer.staffNumber.toString();
        lecturersData[staffNumber] = lecturer;
        res.setHeader("Location", "/faculty/lecturers/" + staffNumber);
        res.statusCode = 200; //200 OK
        _ = res.send();
    }

    // Resource to get a specific lecturer by staff number
    resource function get getLecturerByStaffNumber(http:Request req, http:Response res, string staffNumber) {
        if (lecturersData.exists(staffNumber)) {
            json lecturer = lecturersData[staffNumber];
            res.setJsonPayload(lecturer);
        } else {
            res.statusCode = 404; // Not Found
            res.setJsonPayload("Lecturer not found");
        }
        _ = res.send();
    }

    // Resource to update an existing lecturer
    resource function put updateLecturer(http:Request req, http:Response res, string staffNumber) {
        if (lecturersData.exists(staffNumber)) {
            json updatedLecturer = check req.getJsonPayload();
            lecturersData[staffNumber] = updatedLecturer;
            res.statusCode = 200; //200 OK
        } else {
            res.statusCode = 404; // Not Found
        }
        _ = res.send();
    }

    // Resource to delete a lecturer by staff number
    resource function delete deleteLecturer(http:Request req, http:Response res, string staffNumber) {
        if (lecturersData.exists(staffNumber)) {
            lecturersData.remove(staffNumber);
            res.statusCode = 204; //204 No Content
        } else {
            res.statusCode = 404; // Not Found
        }
        _ = res.send();
    }
}


// In-memory data store for office assignments
    map<string> officeAssignments = {
        "S123": "O101",
        "S456": "O102"
        
    };
service /faculty/offices on new http:Listener(9091) {

    // Resource to get all lecturers sitting in the same office
    resource function get getLecturersInOffice(http:Request req, http:Response res, string officeNumber) {
        json[] lecturers = [];
        foreach key, value in officeAssignments {
            if (value == officeNumber) {
                json lecturer = {
                    "staffNumber": key,
                    "officeNumber": value
                };
                lecturers.push(lecturer);
            }
        }
        res.setJsonPayload(lecturers);
        _ = res.send();
    }
}


// In-memory data store for course assignments
    map<string> courseAssignments = {
        "S123": "DSA612S",
        "S456": "CS101", "CS202"
        
    };

service /faculty/courses on new http:Listener(9092) {

    // Resource to get all lecturers teaching a specific course
    resource function get getLecturersTeachingCourse(http:Request req, http:Response res, string courseCode) {
        json[] lecturers = [];
        foreach key, value in courseAssignments {
            if (value.contains(courseCode)) {
                json lecturer = {
                    "staffNumber": key,
                    "courses": value
                };
                lecturers.push(lecturer);
            }
        }
        res.setJsonPayload(lecturers);
        _ = res.send();
    }
}
