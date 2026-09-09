CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE hotel_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL,
    hotel_id VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    checkin_date DATE NOT NULL,
    checkout_date DATE NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE booking_events (
    id BIGSERIAL PRIMARY KEY,
    booking_id UUID NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_booking FOREIGN KEY(booking_id) REFERENCES hotel_bookings(id) ON DELETE CASCADE
);

-- Compound Index for targeted query execution
CREATE INDEX idx_hotel_bookings_city_created_org_status 
ON hotel_bookings (city, created_at, org_id, status) 
INCLUDE (amount);
