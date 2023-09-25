// client.bal

import ballerina/http;
import ballerina/io;
import ballerina/lang.'int;

final http:Client ClientConnector = check new ("http://localhost:9090");

public function main() returns error? {

    // Prompt the user for input to choose an action
    io:println("Select an action:");
    io:println("1. Get all lecturers");
    io:println("2. Add a new lecturer");
    io:println("3. Get a specific lecturer by staff number");
    io:println("4. Update an existing lecturer");
    io:println("5. Delete a lecturer by staff number");
    io:println("6. Get all lecturers teaching a specific course");
    io:println("7. Get all lecturers sitting in the same office");
    io:println("8. Exit");
    
    string choice = (io:readln("Enter your choice: "));
    int|error y = int:fromString(choice);

    // Performs the selected action
    match choice {
        1 => { getAllLecturers(); }
        2 => { addLecturer(); }
        3 => { getLecturerByStaffNumber(); }
        4 => { updateLecturer(); }
        5 => { deleteLecturer(); }
        6 => { getLecturersTeachingCourse(); }
        7 => { getLecturersInOffice(); }
        8 => { io:println("Exiting..."); }
        _ => { io:println("Invalid choice. Please select a valid option."); }
    }
}


// Function to retrieve all lecturers
function getAllLecturers() {

    string url = "http://localhost:9090/faculty/lecturers"; // Specify the URL
    http:Request request = new;
    request.Path("/faculty/lecturers");

    http:Response|error response = check ClientConnector->get(url, request);
    //http:Response|error response = check http:request("GET", url, request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString()); 
    }
}

// Function to add a new lecturer
function addLecturer() {
    // Creates a new lecturer JSON payload 
    json lecturerJson = {
        "staffNumber": "S123",
        "officeNumber": "O101",
        "staffName": "Isaac Makosa",
        "title": "Junior Lecturer",
        "courses": [
            {
                "courseName": "Distributed Systems and Applications",
                "courseCode": "DSA612S",
                "nqfLevel": 6
            }
        ]
    };

    http:Request request = new;
    request.Path("/faculty/lecturers");
    request.setJsonPayload(lecturerJson);

    http:Response|error response = check ClientConnector->post("http://localhost:9090", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to get a specific lecturer by staff number
function getLecturerByStaffNumber() {
    string staffNumber = io:readln("Enter staff number: ");

    http:Request request = new;
    request.Path("/faculty/lecturers/" + staffNumber);

    http:Response|error response = check ClientConnector->get("http://localhost:9090", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to update an existing lecturer
function updateLecturer() {
    string staffNumber = io:readln("Enter staff number to update: ");

    // Creates an updated lecturer JSON payload 
    json updatedLecturerJson = {
        "staffNumber": staffNumber,
        "officeNumber": "O102",
        "staffName": "Ndinelago Nashandi",
        "title": "Senior Lecturer",
        "courses": [
            {
                "courseName": "Distributed Systems and Applications",
                "courseCode": "DSA612S",
                "nqfLevel": 7
            }
        ]
    };

    http:Request request = new;
    request.Path("/faculty/lecturers/" + staffNumber);
    request.setJsonPayload(updatedLecturerJson);

    http:Response|error response = check ClientConnector->put("http://localhost:9090", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to delete a lecturer by staff number
function deleteLecturer() {
    string staffNumber = io:readln("Enter staff number to delete: ");

    http:Request request = new;
    request.setPath("/faculty/lecturers/" + staffNumber);

    http:Response|error response = check ClientConnector->delete("http://localhost:9090", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to get all lecturers teaching a specific course
function getLecturersTeachingCourse() {
    string courseCode = io:readln("Enter course code: ");

    http:Request request = new;
    request.setPath("/faculty/courses/" + courseCode + "/lecturers");

    http:Response|error response = check ClientConnector->get("http://localhost:9092", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to get all lecturers sitting in the same office
function getLecturersInOffice() {
    string officeNumber = io:readln("Enter office number: ");

    http:Request request = new;
    request.setPath("/faculty/offices/" + officeNumber + "/lecturers");

    http:Response|error response = check ClientConnector->get("http://localhost:9091", request);

    if (response is http:Response) {
        handleResponse(response);
    } else {
        io:println("Error: " + response.toString());
    }
}

// Function to handle API responses
function handleResponse(http:Response response) {
    if (response.statusCode == 200) {
        json result = check response.getJsonPayload();
        io:println(result.toString());
    } else {
        byte[] responseBodyBytes = check response.getBinaryPayload();
        string responseBody =  response.getContentType();
        io:println("Error: " + responseBody);
    }
}
