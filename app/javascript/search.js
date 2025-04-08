document.addEventListener('turbo:load', function() {
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const searchSpinner = document.querySelector('.search-spinner');
  
  if (!searchInput) return;
  
  let searchTimeout;
  let lastQuery = '';
  let lastCompletedQuery = '';
  let typingTimer;
  const doneTypingInterval = 1000; // 1 second
  let originalArticlesHtml = '';
  let hasStoredOriginal = false;
  
  function debounced (func, delay) {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(func, delay);
  }
  
  function performSearch(query) {
    if (query === lastQuery) return;
    lastQuery = query;
  
    if (!hasStoredOriginal && query) {
      originalArticlesHtml = searchResults.innerHTML;
      hasStoredOriginal = true;
    }
  
    if (!query) {
      searchResults.innerHTML = originalArticlesHtml;
      return;
    }
  
    searchSpinner.classList.remove('d-none');
  
    fetch(`/api/v1/search?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        updateSearchResults(data);
        searchSpinner.classList.add('d-none');
      })
      .catch(error => {
        console.error('Error performing search:', error);
        searchSpinner.classList.add('d-none');
      });
  }
  
  
  function updateSearchResults(articles) {
    if (articles.length === 0) {
      searchResults.innerHTML = '<div class="alert alert-info">No articles found matching your search.</div>';
      return;
    }
    
    let html = '<div class="article-list">';
    articles.forEach(article => {
      html += `
        <div class="article-item card mb-3">
          <div class="card-body">
            <h5 class="card-title">${article.title}</h5>
            <p class="card-text">${article.content.substring(0, 150)}...</p>
          </div>
        </div>
      `;
    });
    html += '</div>';
    
    searchResults.innerHTML = html;
  }
  
  function recordSearch(query) {
    if (!query) return;
    
    fetch('/api/v1/record_search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ query: query })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        lastCompletedQuery = query;
      }
    })
    .catch(error => {
      console.error('Error recording search:', error);
    });
  }
  
  searchInput.addEventListener('input', function() {
    const query = this.value.trim();
    
    clearTimeout(typingTimer);
    
    debounced (() => performSearch(query), 300);
    
    typingTimer = setTimeout(() => {
      if (query && query !== lastCompletedQuery) {
        recordSearch(query);
      }
    }, doneTypingInterval);
  });
  
  searchInput.addEventListener('keyup', function() {
    clearTimeout(typingTimer);
    
    const query = this.value.trim();
    if (query) {
      typingTimer = setTimeout(() => {
        if (query !== lastCompletedQuery) {
          recordSearch(query);
        }
      }, doneTypingInterval);
    }
  });
});
