document.addEventListener("DOMContentLoaded", function() {
    const dp1 = document.getElementById("start");
    const dp2 = document.getElementById("end");
    const monthYear = document.getElementById('monthYear');
    const calendarBody = document.getElementById('calendar-body');

    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();
    let selectedStartDate = null;
    let selectedEndDate = null;

    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.", "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

	function renderCalendar(month, year) {
	    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.", "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];
	    const calendarBody = document.getElementById('calendar-body');
	    calendarBody.innerHTML = '';
	    let firstDay = (new Date(year, month).getDay() + 6) % 7;
	    const daysInMonth = 32 - new Date(year, month, 32).getDate();
	    let date = 1;
		monthYear.textContent = monthNames[month] + " " + year;
	    for (let i = 0; i < 6; i++) {
	        let row = document.createElement('tr');
	        for (let j = 0; j < 7; j++) {
	            let cell = document.createElement('td');
	            if (i === 0 && j < firstDay || date > daysInMonth) {
	                cell.appendChild(document.createTextNode(''));
	            } else {
	                let fullDate = `${year}-${(month+1).toString().padStart(2, '0')}-${date.toString().padStart(2, '0')}`;
	                cell.setAttribute('data-date', fullDate);
	                cell.appendChild(document.createTextNode(date));
	                cell.className += getLeaveClass(leaveData[fullDate]);
	                date++;
	            }
	            row.appendChild(cell);
	        }
	        calendarBody.appendChild(row);
	    }
	}

	function getLeaveClass(count) {
	    if (!count) return ''; // No leaves
	    if (count === 1) return ' leave-1';
	    if (count === 2) return ' leave-2';
	    if (count === 3) return ' leave-3';
	    if (count > 3) return ' leave-more';
	    return '';
	}



    function highlightDate() {
        selectedStartDate = dp1.value ? new Date(dp1.value) : null;
        selectedEndDate = dp2.value ? new Date(dp2.value) : null;

        if (selectedStartDate) {
            selectedStartDate.setHours(0, 0, 0, 0);
            currentMonth = selectedStartDate.getMonth();
            currentYear = selectedStartDate.getFullYear();
        }

        if (selectedEndDate) {
            selectedEndDate.setHours(23, 59, 59, 999);
            if (selectedEndDate < selectedStartDate) {
                dp2.value = dp1.value;
                selectedEndDate = new Date(selectedStartDate);
                selectedEndDate.setHours(23, 59, 59, 999);
            }
        }

        renderCalendar(currentMonth, currentYear);
    }

    function previousMonth() {
        currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
        currentYear = (currentMonth === 11) ? currentYear - 1 : currentYear;
        renderCalendar(currentMonth, currentYear);
    }

    function nextMonth() {
        currentMonth = (currentMonth + 1) % 12;
        currentYear = (currentMonth === 0) ? currentYear + 1 : currentYear;
        renderCalendar(currentMonth, currentYear);
    }

    document.querySelector('.navigation button:first-child').addEventListener('click', previousMonth);
    document.querySelector('.navigation button:last-child').addEventListener('click', nextMonth);

    renderCalendar(currentMonth, currentYear);
});