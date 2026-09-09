INSERT INTO hotel_bookings (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT 
    gen_random_uuid(),
    (ARRAY[
        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 
        'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22'::uuid, 
        'c2aabc99-9c0b-4ef8-bb6d-6bb9bd380a33'::uuid
    ])[floor(random() * 3 + 1)],
    'HOTEL-' || floor(random() * 50 + 1)::text,
    (ARRAY['delhi', 'mumbai', 'bangalore', 'singapore'])[floor(random() * 4 + 1)],
    CURRENT_DATE + (floor(random() * 10)::int || ' days')::interval,
    CURRENT_DATE + (floor(random() * 10 + 11)::int || ' days')::interval,
    (random() * 500 + 50)::numeric(12,2),
    (ARRAY['CONFIRMED', 'CANCELLED', 'PENDING'])[floor(random() * 3 + 1)],
    NOW() - (random() * 60 || ' days')::interval
FROM generate_series(1, 150);

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT 
    id,
    'BOOKING_CREATED',
    jsonb_build_object('source', 'web_checkout', 'ip', '192.168.1.1'),
    created_at
FROM hotel_bookings
LIMIT 80;
