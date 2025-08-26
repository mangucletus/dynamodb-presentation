#!/bin/bash

# DynamoDB Student Records Demo Script
# Demonstrates table creation, GSI, queries, scans, PartiQL, PITR, and cleanup

echo "Starting DynamoDB Student Records Demo..."

# Step 1: Create StudentRecords Table
# Composite primary key: StudentId (HASH), CourseName (RANGE)
# Uses PAY_PER_REQUEST for simplicity
echo "Creating StudentRecords table..."
aws dynamodb create-table \
    --table-name StudentRecords \
    --attribute-definitions \
        AttributeName=StudentId,AttributeType=S \
        AttributeName=CourseName,AttributeType=S \
        AttributeName=Grade,AttributeType=N \
    --key-schema \
        AttributeName=StudentId,KeyType=HASH \
        AttributeName=CourseName,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Wait for table to be active (~10 seconds)
echo "Waiting for table to be active..."
aws dynamodb wait table-exists --table-name StudentRecords
echo "Table created."

# Create Global Secondary Index (GSI): CourseGrades-GSI
# Partition key: CourseName, Sort key: Grade
echo "Creating CourseGrades-GSI..."
aws dynamodb update-table \
    --table-name StudentRecords \
    --attribute-definitions \
        AttributeName=CourseName,AttributeType=S \
        AttributeName=Grade,AttributeType=N \
    --global-secondary-index-updates \
        "[{\"Create\":{\"IndexName\":\"CourseGrades-GSI\",\"KeySchema\":[{\"AttributeName\":\"CourseName\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"Grade\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"},\"ProvisionedThroughput\":{\"ReadCapacityUnits\":5,\"WriteCapacityUnits\":5}}}]"

# Wait for GSI to be active (~10-20 seconds)
echo "Waiting for GSI to be active..."
aws dynamodb wait table-exists --table-name StudentRecords
echo "GSI created."

# Step 2: Add Sample Student Records
echo "Adding sample student records..."
aws dynamodb put-item \
    --table-name StudentRecords \
    --item '{
        "StudentId": {"S": "S101"},
        "CourseName": {"S": "Mathematics"},
        "Grade": {"N": "85"},
        "Attendance": {"N": "90"},
        "Credits": {"N": "3"}
    }'

aws dynamodb put-item \
    --table-name StudentRecords \
    --item '{
        "StudentId": {"S": "S102"},
        "CourseName": {"S": "Mathematics"},
        "Grade": {"N": "92"},
        "Attendance": {"N": "95"},
        "Credits": {"N": "3"}
    }'

aws dynamodb put-item \
    --table-name StudentRecords \
    --item '{
        "StudentId": {"S": "S101"},
        "CourseName": {"S": "Physics"},
        "Grade": {"N": "88"},
        "Attendance": {"N": "85"},
        "Credits": {"N": "4"}
    }'
echo "Sample records added."

# Query by Primary Key (StudentId = S101)
echo "Querying all courses for StudentId = S101..."
aws dynamodb query \
    --table-name StudentRecords \
    --key-condition-expression "StudentId = :sid" \
    --expression-attribute-values '{":sid": {"S": "S101"}}'

# Scan with Filter (Grade > 90)
echo "Scanning for students with Grade > 90..."
aws dynamodb scan \
    --table-name StudentRecords \
    --filter-expression "Grade > :g" \
    --expression-attribute-values '{":g": {"N": "90"}}'

# Update an Item (Change Grade for S101's Mathematics)
echo "Updating Grade for S101's Mathematics to 88..."
aws dynamodb update-item \
    --table-name StudentRecords \
    --key '{"StudentId": {"S": "S101"}, "CourseName": {"S": "Mathematics"}}' \
    --update-expression "SET Grade = :g" \
    --expression-attribute-values '{":g": {"N": "88"}}'

# PartiQL Query (Table: Select S101's courses)
echo "Running PartiQL query for S101's courses..."
aws dynamodb execute-statement \
    --statement "SELECT * FROM \"StudentRecords\" WHERE \"StudentId\" = 'S101'"

# PartiQL Query (GSI: Students in Mathematics by Grade)
echo "Running PartiQL query on CourseGrades-GSI for Mathematics..."
aws dynamodb execute-statement \
    --statement "SELECT CourseName, Grade, StudentId FROM \"StudentRecords\".\"CourseGrades-GSI\" WHERE CourseName = 'Mathematics' ORDER BY Grade DESC"

# Step 3: Enable Point-in-Time Recovery (PITR)
echo "Enabling PITR for StudentRecords..."
aws dynamodb update-continuous-backups \
    --table-name StudentRecords \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
echo "PITR enabled."

# Step 4: Clean Up
echo "Deleting StudentRecords table..."
aws dynamodb delete-table --table-name StudentRecords
echo "Table deleted. Demo complete."