
        document.addEventListener("DOMContentLoaded", function() {
            var dp1 = document.getElementById("start");
            var dp2 = document.getElementById("end");

            if (dp1) {
                dp1.addEventListener("change", function() {
                    console.log('New Start Date:', dp1.value);
                    // Set the minimum date for dp2
                    dp2.min = dp1.value;
                    if (dp2.value < dp1.value) {
                        dp2.value = ''; // Reset dp2 if it's less than dp1
                    }
                });
            }

            if (dp2) {
                dp2.addEventListener("change", function() {
                    if (dp2.value < dp1.value) {
                        alert("Data de final nu poate fi mai mică decât cea de început!");
                        dp2.value = dp1.value; // Optional: automatically adjust dp2 to match dp1
                    }
                    console.log('New End Date:', dp2.value);
                });
            }
        });
   
    let today = new Date();
    let currentMonth = today.getMonth();
    let currentYear = today.getFullYear();
    let selectedStartDate = null;
    let selectedEndDate = null;

    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.",
        "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

    function generateCalendar(month, year) {
        let firstDay = (new Date(year, month)).getDay();
        let daysInMonth = 32 - new Date(year, month, 32).getDate();
        let tbl = document.getElementById("calendar-body");
        tbl.innerHTML = "";

        document.getElementById("monthYear").innerHTML = monthNames[month] + " " + year;

        firstDay = (firstDay === 0) ? 6 : firstDay - 1;  // Monday-based adjustment

        let date = 1;
        for (let i = 0; i < 6; i++) {
            let row = document.createElement("tr");
            for (let j = 0; j < 7; j++) {
                if (i === 0 && j < firstDay) {
                    let cell = document.createElement("td");
                    let cellText = document.createTextNode("");
                    cell.appendChild(cellText);
                    row.appendChild(cell);
                } else if (date > daysInMonth) {
                    break;
                } else {
                    let cell = document.createElement("td");
                    let cellText = document.createTextNode(date);
                    cell.appendChild(cellText);
                    if (selectedStartDate && selectedEndDate && isDateInRange(date, month, year)) {
                        cell.classList.add('highlight');
                    }
                    row.appendChild(cell);
                    date++;
                }
            }
            tbl.appendChild(row);
        }
    }

    function isDateInRange(day, month, year) {
        let date = new Date(year, month, day);
        date.setHours(0, 0, 0, 0);
        return date >= selectedStartDate && date <= selectedEndDate;
    }

    function highlightDate() {
        const startDatePicker = document.getElementById('start');
        const endDatePicker = document.getElementById('end');
        selectedStartDate = startDatePicker.value ? new Date(startDatePicker.value) : null;
        selectedEndDate = endDatePicker.value ? new Date(endDatePicker.value) : null;

        if (selectedStartDate) {
            selectedStartDate.setHours(0, 0, 0, 0);
            currentMonth = selectedStartDate.getMonth();  // Update current month to selected start date's month
            currentYear = selectedStartDate.getFullYear(); // Update current year
        }

        if (selectedEndDate) {
            selectedEndDate.setHours(23, 59, 59, 999);
            if (selectedEndDate < selectedStartDate) {
                endDatePicker.value = startDatePicker.value;
                selectedEndDate = new Date(selectedStartDate);
                selectedEndDate.setHours(23, 59, 59, 999);
            }
        }

        generateCalendar(currentMonth, currentYear);
    }

    function previousMonth() {
        currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
        currentYear = (currentMonth === 11) ? currentYear + 1 : currentYear;
        generateCalendar(currentMonth, currentYear);
    }

    function nextMonth() {
        currentMonth = (currentMonth + 1) % 12;
        currentYear = (currentMonth === 0) ? currentYear + 1 : currentYear;
        generateCalendar(currentMonth, currentYear);
    }

    document.addEventListener('DOMContentLoaded', function() {
        generateCalendar(currentMonth, currentYear);
        document.getElementById('start').addEventListener('change', highlightDate);
        document.getElementById('end').addEventListener('change', highlightDate);
    });
