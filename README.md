# DynamoDB Student Records Demo

## Overview
This repository provides step-by-step instructions for a DynamoDB demo using the AWS Management Console, showcasing a `StudentRecords` database. The demo covers creating a table, adding a Global Secondary Index (GSI), performing querying and scanning operations (including PartiQL), enabling Point-in-Time Recovery (PITR), and cleaning up resources. 

## Objectives
- Understand how to use DynamoDB with a simple Student Records database.
- Perform the following tasks in the AWS Console:
  - Create a table and a Global Secondary Index (GSI).
  - Execute querying and scanning operations on the table and index.
  - Enable Point-in-Time Recovery (PITR).
  - Clean up resources to avoid charges.

## Prerequisites
- **AWS Account**: Access to the AWS Management Console with DynamoDB permissions (`dynamodb:*`).
- **Browser**: Modern browser (e.g., Chrome, Firefox) for accessing the AWS Console.
- **Optional**: Basic familiarity with DynamoDB concepts (tables, keys, indexes).

## Setup
1. Log in to the [AWS Management Console](https://console.aws.amazon.com).
2. Ensure your IAM user/role has permissions for DynamoDB (`dynamodb:*`).
3. Set your region (e.g., `us-east-1`) in the top-right corner of the console.

## Demo Instructions

### Step 1: Create a Table and a Global Secondary Index
1. **Open DynamoDB**:
   - In the AWS Console, search for "DynamoDB" in the top search bar and select it.
2. **Create a Table**:
   - Navigate to **Tables** → Click **Create table**.
   - **Table name**: Enter `StudentRecords`.
   - **Partition key**: Enter `StudentId` (Type: String).
   - **Sort key**: Enter `CourseName` (Type: String).
   - Select **Use default settings** → Click **Create table**.
   - Wait ~10 seconds, refreshing until **Status** = `Active`.
3. **Create a Global Secondary Index (GSI)**:
   - Open the `StudentRecords` table.
   - Go to **Indexes** tab → Click **Create index**.
   - **Partition key**: Enter `CourseName` (Type: String).
   - **Sort key**: Enter `Grade` (Type: Number).
   - **Index name**: Enter `CourseGrades-GSI`.
   - Leave default settings → Click **Create index**.
   - Wait ~10-20 seconds until GSI **Status** = `Active`.

**Note**: The table uses a composite primary key (`StudentId` + `CourseName`) for student-specific queries. The GSI enables queries by `CourseName` and `Grade`.

### Step 2: Querying and Scanning Operations
1. **Create Items in the Table**:
   - In the `StudentRecords` table, go to **Items** tab → Click **Create item**.
   - Add an item:
     - **StudentId**: `S101` (String)
     - **CourseName**: `Mathematics` (String)
     - **Grade**: `85` (Number)
     - **Attendance**: `90` (Number)
     - **Credits**: `3` (Number)
   - Click **Save**.
   - Repeat to add two more items:
     - Item 2: `StudentId: S102`, `CourseName: Mathematics`, `Grade: 92`, `Attendance: 95`, `Credits: 3`
     - Item 3: `StudentId: S101`, `CourseName: Physics`, `Grade: 88`, `Attendance: 85`, `Credits: 4`
   - Confirm all items appear in the **Items** tab.
2. **Run a Query (Primary Key-based)**:
   - Go to **Explore table items** → Select `StudentRecords` → Click **Query**.
   - Enter **Partition key**: `StudentId = S101`.
   - Click **Run** → View all courses for student `S101` (e.g., Mathematics, Physics).
3. **Run a Scan**:
   - Go to **Explore table items** → Select `StudentRecords` → Click **Scan**.
   - Add filter: `Grade > 90` (Number).
   - Click **Run** → View students with grades above 90 (e.g., `S102` in Mathematics).
4. **Edit an Item**:
   - In **Items** tab, select the item: `StudentId = S101`, `CourseName = Mathematics`.
   - Click **Actions** → **Edit** → Change `Grade` to `88`.
   - Click **Save** → Confirm the update in the **Items** tab.
5. **Use PartiQL (SQL-like Queries)**:
   - Go to **PartiQL editor** in the DynamoDB console.
   - Run query for table:
     ```sql
     SELECT * FROM "StudentRecords" WHERE "StudentId" = 'S101';
     ```
     → Returns all courses for `S101`.
   - Run query for GSI:
     ```sql
     SELECT CourseName, Grade, StudentId
     FROM "StudentRecords"."CourseGrades-GSI"
     WHERE CourseName = 'Mathematics'
     ORDER BY Grade DESC;
     ```
     → Returns students in Mathematics ranked by grade (e.g., `S102: 92`, `S101: 88`).

### Step 3: Enable Point-in-Time Recovery (PITR)
1. In DynamoDB, select the `StudentRecords` table.
2. Go to **Backups** tab → Click **Edit**.
3. Check **Enable Point-in-time recovery (PITR)** → Click **Save**.
4. Confirm **PITR** status = `On` (enables continuous backups for 35 days).

### Step 4: Clean Up Resources
1. In DynamoDB, select the `StudentRecords` table.
2. Click **Actions** → **Delete table**.
3. Type `confirm` in the prompt → Click **Delete**.
4. Wait ~10 seconds and verify the table is deleted (no longer listed in **Tables**).

## Example Outputs
- **Query (S101’s courses)**:
  ```json
  [
      {
          "StudentId": "S101",
          "CourseName": "Mathematics",
          "Grade": 88,
          "Attendance": 90,
          "Credits": 3
      },
      {
          "StudentId": "S101",
          "CourseName": "Physics",
          "Grade": 88,
          "Attendance": 85,
          "Credits": 4
      }
  ]
  ```
- **GSI PartiQL (Mathematics by Grade)**:
  ```json
  [
      {
          "CourseName": "Mathematics",
          "Grade": 92,
          "StudentId": "S102"
      },
      {
          "CourseName": "Mathematics",
          "Grade": 88,
          "StudentId": "S101"
      }
  ]
  ```

## Notes
- **Table Structure**: Composite key (`StudentId` + `CourseName`) for student-specific queries; GSI (`CourseName` + `Grade`) for course-grade rankings.
- **Operations**:
  - Query: Fetch student courses (Slide 8).
  - Scan: Find high performers (Slide 8).
  - Update: Modify grades (Slide 8).
  - PartiQL: SQL-like queries for table/GSI (Slide 9).
  - PITR: Continuous backups (Slide 13).
- **Cost**: Uses DynamoDB free tier (25GB storage, 25 RCUs/WCUs). 