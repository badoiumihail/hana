# Hana

A platform where existing service businesses (salons, barbers, nail studios) let customers book appointments with their staff, and where customers review the businesses they've visited.

## Language

### Parties

**Business**:
A service business registered on the platform that offers Services performed by its Staff Members.
_Avoid_: Shop, salon, vendor, tenant

**Category**:
A kind of Business from a fixed, platform-defined list (e.g. Barber, Hair salon, Nails). A Business has one or more.
_Avoid_: Type, tag, industry

**Owner**:
A person who manages a Business: its Services, its Staff Members, and all of its Bookings.
_Avoid_: Admin, manager

**Staff Member**:
A person working at a Business who performs Services and can be booked. Manages only their own Working Hours, Time Off and Bookings.
_Avoid_: Employee, specialist, provider, worker

**Customer**:
A person who books Services at Businesses. Any person on the platform can act as a Customer, including Owners and Staff Members at other Businesses.
_Avoid_: Client, user, guest

### Booking

**Service**:
Something a Business offers that a Customer can book, with a fixed duration (e.g. "men's haircut, 45 min").
_Avoid_: Treatment, offering, product

**Booking**:
A Customer's claim on one Staff Member for one Service over a time range. Every Booking that is not declined or cancelled blocks its time range.
_Avoid_: Reservation, appointment, Hold

**Booking status**:
Where a Booking is in its lifecycle: requested, confirmed, declined, cancelled, completed, or no-show.

**Requested**:
A Booking awaiting confirmation by the Business. It already blocks its time range.
_Avoid_: Pending, Hold

**Auto-decline**:
What happens to a requested Booking the Business doesn't answer in time: it is declined automatically, freeing its time range.

**Cancellation cutoff**:
A per-Business time before a Booking's start after which only the Business, not the Customer, can cancel it.

**Cancellation reason**:
Why the Business cancelled a Booking: at the Customer's request, or for a Business reason. Required whenever the Business cancels.

**Late cancellation**:
A Booking cancelled by the Business at the Customer's request after the Cancellation cutoff. Counts against the Customer's reliability.

**Auto-confirm**:
A per-Business setting under which new Bookings skip the requested state and are confirmed immediately.

**No-show**:
A Booking outcome meaning the Customer did not turn up; the Service was never provided. Still blocks its time range, and can never be reviewed.

**Completed**:
A Booking whose Service is taken as provided. A confirmed Booking becomes completed automatically once its Correction window closes.

**Correction window**:
The period from 15 minutes after a Booking starts until 2 hours after it ends, during which staff may mark or unmark a No-show. When it closes, the outcome is final.

### Availability

**Working Hours**:
The recurring weekly schedule during which a Staff Member can be booked, in local clock time of the Business's time zone.
_Avoid_: Shifts, opening hours

**Time Off**:
A period a Staff Member explicitly blocks so it can't be booked. It may not overlap a Booking that blocks its time range.
_Avoid_: Unavailability, blocked slot, absence

**Availability**:
A Staff Member's bookable time: Working Hours minus Time Off minus blocking Bookings. Always computed, never stored.
_Avoid_: Free slots, openings

### Reputation

**Review**:
A Customer's rating of a Business, allowed only for a completed Booking, at most one per Booking.
_Avoid_: Rating, feedback, testimonial
