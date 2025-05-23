function initializeAnalytics() {
  const searchInput = document.getElementById('searchInput');
  const topSearchesChart = document.getElementById('topSearchesChart');
  const userSearchesChart = document.getElementById('userSearchesChart');
  let debounceTimer;
  let isSearching = false;
  const DEBOUNCE_DELAY = 1000;

  if (!searchInput || !topSearchesChart || !userSearchesChart) {
    console.error('Required elements not found');
    return;
  }

  let topSearchesChartInstance = null;
  let userSearchesChartInstance = null;

  function extractTableData(tableId) {
    const table = document.getElementById(tableId);
    if (!table) return { labels: [], data: [] };
    
    const rows = table.querySelectorAll('tbody tr');
    const labels = [];
    const data = [];
    
    rows.forEach(row => {
      const cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        labels.push(cells[0].textContent);
        data.push(parseInt(cells[1].textContent));
      }
    });
    
    return { labels, data };
  }

  function createChart(canvas, labels, data, title) {
    if (!canvas) return null;
    
    return new Chart(canvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: title,
          data: data,
          backgroundColor: 'rgba(54, 162, 235, 0.6)',
          borderColor: 'rgb(54, 162, 235)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Count'
            }
          },
          x: {
            title: {
              display: true,
              text: 'Search Terms'
            }
          }
        }
      }
    });
  }

  function updateCharts(topSearches, userSearches) {
    try {
      if (topSearchesChartInstance) {
        topSearchesChartInstance.destroy();
      }
      const topLabels = Object.keys(topSearches);
      const topData = Object.values(topSearches);
      topSearchesChartInstance = createChart(topSearchesChart, topLabels, topData, 'Top Searches');

      if (userSearchesChartInstance) {
        userSearchesChartInstance.destroy();
      }
      const userLabels = userSearches.map(s => s.query);
      const userData = userSearches.map(s => s.search_count);
      userSearchesChartInstance = createChart(userSearchesChart, userLabels, userData, 'Your Searches');
    } catch (error) {
      console.error('Error updating charts:', error);
    }
  }

  function debounce(func, delay) {
    return function() {
      const context = this;
      const args = arguments;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => func.apply(context, args), delay);
    };
  }

  function updateTable(tableId, data) {
    const table = document.getElementById(tableId);
    if (!table) return;

    const tbody = table.querySelector('tbody');
    if (!tbody) return;
    
    tbody.innerHTML = '';

    if (typeof data === 'object') {
      if (Array.isArray(data)) {
        data.forEach(search => {
          const row = document.createElement('tr');
          row.innerHTML = `
            <td>${search.query}</td>
            <td>${search.search_count}</td>
          `;
          tbody.appendChild(row);
        });
      } else {
        Object.entries(data).forEach(([query, count]) => {
          const row = document.createElement('tr');
          row.innerHTML = `
            <td>${query}</td>
            <td>${count}</td>
          `;
          tbody.appendChild(row);
        });
      }
    }
  }

  function updateTables(topSearches, userSearches) {
    updateTable('topSearchesTable', topSearches);
    updateTable('userSearchesTable', userSearches);
  }

  function trackSearch(query) {
    if (isSearching) return;
    if (!query || query.length <= 3) return;

    isSearching = true;
    const url = new URL('/search', window.location.origin);
    url.searchParams.append('query', query);

    fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      if (data.status === 'success') {
        updateTables(data.top_searches, data.user_searches);
        updateCharts(data.top_searches, data.user_searches);
      } else {
        console.error('Search failed:', data);
      }
    })
    .catch(error => console.error('Error:', error))
    .finally(() => {
      isSearching = false;
    });
  }

  // Initialize charts with existing data
  const topSearchesData = extractTableData('topSearchesTable');
  const userSearchesData = extractTableData('userSearchesTable');
  
  if (topSearchesData.labels.length > 0) {
    topSearchesChartInstance = createChart(topSearchesChart, topSearchesData.labels, topSearchesData.data, 'Top Searches');
  }
  
  if (userSearchesData.labels.length > 0) {
    userSearchesChartInstance = createChart(userSearchesChart, userSearchesData.labels, userSearchesData.data, 'Your Searches');
  }

  searchInput.addEventListener('input', debounce(function(e) {
    const query = e.target.value.trim();
    trackSearch(query);
  }, DEBOUNCE_DELAY));
}

document.addEventListener('turbo:load', initializeAnalytics);
document.addEventListener('turbo:render', initializeAnalytics);
