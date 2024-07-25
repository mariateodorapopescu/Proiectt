/**
 * 
 */
document.addEventListener('DOMContentLoaded', function() {
    const monthYear = document.getElementById('monthYear');
    const calendarBody = document.getElementById('calendar-body');

	if (dp1 && dp2) {
	    dp1.addEventListener("change", updateEndDate);
	    dp2.addEventListener("change", validateDates);
	    dp1.addEventListener("change", function() {
	        dp2.min = dp1.value;
	        if (dp2.value < dp1.value) {
	            dp2.value = ''; // Reset dp2 if it's less than dp1
	        }
	    });
	}

	// Ensures that the end date is not before the start date
	function updateEndDate() {
	    if (dp2.value < dp1.value) {
	        dp2.value = dp1.value;
	    }
	    highlightDate();
	}
	
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();

    function renderCalendar(month, year) {
        calendarBody.innerHTML = '';

        const firstDay = new Date(year, month).getDay();
        const daysInMonth = 32 - new Date(year, month, 32).getDate();

        let date = 1;
        for (let i = 0; i < 6; i++) {
            let row = document.createElement('tr');

            for (let j = 0; j < 7; j++) {
                if (i === 0 && j < firstDay) {
                    let cell = document.createElement('td');
                    let cellText = document.createTextNode('');
                    cell.appendChild(cellText);
                    row.appendChild(cell);
                } else if (date > daysInMonth) {
                    break;
                } else {
                    let cell = document.createElement('td');
                    let cellText = document.createTextNode(date);
                    cell.setAttribute('data-date', `${year}-${String(month + 1).padStart(2, '0')}-${String(date).padStart(2, '0')}`);
                    cell.appendChild(cellText);
                    row.appendChild(cell);
                    date++;
                }
            }
            calendarBody.appendChild(row);
        }
        monthYear.innerText = `${month + 1} - ${year}`;
    }

	function previousMonth() {
	    if (currentMonth === 0) {  // If it's January and we need to go to the previous month,
	        currentMonth = 11;     // set it to December
	        currentYear--;         // and decrement the year
	    } else {
	        currentMonth--;        // Otherwise, just decrement the month
	    }
	    renderCalendar(currentMonth, currentYear);
	    updateCalendarDisplay(currentYear, currentMonth);
	}

	function nextMonth() {
	    if (currentMonth === 11) { // If it's December and we need to go to the next month,
	        currentMonth = 0;      // set it to January
	        currentYear++;         // and increment the year
	    } else {
	        currentMonth++;        // Otherwise, just increment the month
	    }
	    renderCalendar(currentMonth, currentYear);
	    updateCalendarDisplay(currentYear, currentMonth);
	}


    document.querySelector('.navigation button:first-child').addEventListener('click', previousMonth);
    document.querySelector('.navigation button:last-child').addEventListener('click', nextMonth);

    renderCalendar(currentMonth, currentYear);
});
