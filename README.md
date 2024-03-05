# README

This is Bridgette (Bee) McBride's solution to a timeboxed interview scenario, wherein the goal is to create a RESTful API that allows providers to schedule their availability and clients may book a time in advance from that schedule. 

## Notes on my solution
1. Time Zones. My initial intent was to provide a solution that handled time zones as well (for users attempting to book an appointment in a different zone than they were in) and this caused issues that I didn't spend too much time debugging. This would have been handled by a proper database framework. 
2. DateTime formatting. Related to the point on timezones, I initially provided a format that I expected my datetimes to be sent in. During the course of testing, this caused some issues, and I did not fully solve them. This would be resolved either by using the proper database framework or by having a standardized approach to DateTime parsing. 
3. Appointment creation. I did not have "viewing available times" and "creating a new appointment" be in the same endpoint purposefully. These are separate concerns and the UI should handle calling the different endpoints. 
4. Appointment confirmation. Ideally, this would be a unique URL for confirming the appointment where the appointment ID is in the header, or otherwise hidden from the user. This way, we are not exposing information when we should not be. For this project though, it's just the POST body and that's fine. 
5. Rigid time slot for availability. I initially went with a hardcoded 15 minute chunk per the requirements. In production, a more extensible solution would be more flexible and allow for arbitrary time frames. This would potentially require some rework in the provider availability submission, as it currently splits into 15-minute chunks, but that would be discussed as part of how to make the solution more extensible. 
6. Confirmation of appointment. I wanted to be able to supply test data, so I implemented a crude JSON-file DB ... thing. This resulted in a number of irritations, including the difficulties with changing existing data. As an example, confirming an appointment creates a duplicate because I did not also spend the time to create a fully functional database plugin. With a bit more time, I would have implemented ActiveRecord. 
7. Biggest thing: before letting this anywhere NEAR production, everything that can have unit tests should have them, and there should be feedback gathered before this is released to everyone. A phased rollout or otherwise, depending on user groups. 

## How to run: 
1. Clone this repo. If needed, ensure you have ruby & rails on the machine you cloned this to. The data for this is stored in `app/db/mock_db/` in .json files for ease of setup, rather than setting up a PostgreSQL DB with this as well. Obviously, because of this, there are trade offs that are made that would not have to be made if we were using a real db and could use ActiveRecord or some other database connection library/framework/etc. 
2. Start up the rails server by opening a command prompt in the root directory and running `rails s`. This will run the server on http://localhost:3000/. 
3. Ensure you can submit new availability for a provider via a POST to http://localhost:3000/availabilities/ with body in the format: 
```
{
    "provider_id": 1,
    "start_date_time": "2024-03-10T09:00",
    "end_date_time": "2024-03-12T17:00"
}
```
This should make as many 15-minute time slots as fit in the time given, without the provider having to split it out themself. 
4. Ensure a client can see available appointment slots (in JSON format) at http://localhost:3000/availabilities/.
5. Ensure a client can reserve an available appointment slot by creating an appointment, via a POST to http://localhost:3000/appointments/ with body in the format: 
```
{
    "provider_id": 5, 
    "client_id": 4, 
    "appointment_date_time": "2024-03-12T11:00:00-08:00", 
    "time_zone": "PST"
}
```
6. Ensure a client can confirm their appointment via a PUT to http://localhost:3000/appointments/confirm with body in the format: 
```
{
    "appointment_id": "3"
}
```
7. Appointments can be viewed via GET http://localhost:3000/appointments/. Similarly, providers, clients (not that this was asked for), and availability can be viewed the same way. 


## Prompt: 

## Scenario

Henry has two kinds of users, **providers** and **clients**. Providers have a schedule where they are available to see clients. Clients want to book an appointment time, in advance, from that schedule.

## Task

Build an API (e.g. RESTful) with the following endpoints:

- Allows providers to submit times they are available for appointments
    - e.g. On Friday the 13th of August, Dr. Jekyll wants to work between 8am and 3pm
- Allows a client to retrieve a list of available appointment slots
    - Appointment slots are 15 minutes long
- Allows clients to reserve an available appointment slot
- Allows clients to confirm their reservation

Additional Requirements:

- Reservations expire after 30 minutes if not confirmed and are again available for other clients to reserve that appointment slot
- Reservations must be made at least 24 hours in advance

## Limitations

Do not use an off-the-shelf reservation system. While suitable in real world, this is a code challenge.

Development time should be limited to about 2 or 3 hours. Feel free to provide notes of the areas that could not be met within that timeframe, tradeoffs made to stay within that time frame, or areas which would be handled differently before a production deployment.

## Submission

Please email a public link to your git repo to codechallenge@henrymeds.com.

## Evaluation

This will be evaluated similar to a real-world submission, including:

- Does the code solve the business problem?
- What trade-offs were made, how wise are they?
- How clean/well structured is the code?
- What ‘extra’ factors are there, that show exceptional talent?

