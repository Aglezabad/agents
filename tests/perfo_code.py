# Test Input: PERFO — Performance Issues

Analyze the following Python code for performance problems:

```python
import requests

def get_user_details(user_ids):
    """Fetch full user details for a list of user IDs."""
    results = []
    for uid in user_ids:
        response = requests.get(f"https://api.example.com/users/{uid}")
        user = response.json()
        
        # Fetch orders for this user
        orders_resp = requests.get(f"https://api.example.com/users/{uid}/orders")
        user['orders'] = orders_resp.json()
        
        # Fetch profile for this user
        profile_resp = requests.get(f"https://api.example.com/users/{uid}/profile")
        user['profile'] = profile_resp.json()
        
        results.append(user)
    return results

def find_duplicates(items):
    """Find all duplicate items in a list."""
    duplicates = []
    for i in range(len(items)):
        for j in range(len(items)):
            if i != j and items[i] == items[j] and items[i] not in duplicates:
                duplicates.append(items[i])
    return duplicates

def process_large_file(filename):
    """Process a large CSV file line by line."""
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    processed = []
    for line in lines:
        # Skip empty lines
        if line.strip():
            parts = line.split(',')
            # Reconstruct the line with trimmed values
            new_line = ','.join([p.strip() for p in parts])
            processed.append(new_line)
    
    # Write back to file
    with open(filename + '.processed', 'w') as f:
        f.write('\n'.join(processed))
    
    return len(processed)
```

Issues intentionally present:
- N+1 API calls in `get_user_details` (makes 3 sequential HTTP requests per user)
- O(n²) duplicate detection in `find_duplicates`
- `readlines()` loads entire file into memory in `process_large_file`
- No connection pooling for HTTP requests
- No batching or parallelization
