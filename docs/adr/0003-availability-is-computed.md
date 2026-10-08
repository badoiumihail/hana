# Availability is computed, never stored as slot rows

A Staff Member's Availability is calculated when requested, from Working Hours minus Time Off minus blocking Bookings. We do not pre-generate a row per time slot. Pre-generated slots look simpler and faster but break whenever Service durations change, Working Hours shift, or a Service doesn't fit the slot grid, and they duplicate the truth that Bookings already hold. If Availability queries get slow, fix them with indexes and query work (or caching), not by materialising slots.
