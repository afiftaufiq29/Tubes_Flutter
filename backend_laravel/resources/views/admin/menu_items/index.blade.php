<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Menu Items</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 20px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #ff8c00;
            margin-bottom: 30px;
            font-size: 2em;
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            opacity: 1;
            transition: opacity 0.6s ease-in-out;
        }
        .alert.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .button-group {
            text-align: right;
            margin-bottom: 20px;
        }
        .button-group a {
            background-color: #ff8c00;
            color: white;
            padding: 10px 18px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .button-group a:hover {
            background-color: #e07b00;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table th, table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        table th {
            background-color: #f2f2f2;
            color: #555;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 0.85em;
        }
        table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        table tbody tr:hover {
            background-color: #f1f1f1;
        }
        .item-image {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            vertical-align: middle;
            margin-right: 10px;
        }
        .item-name {
            display: inline-block;
            vertical-align: middle;
            font-weight: bold;
        }
        .capitalize {
            text-transform: capitalize;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
        }
        .status-available {
            background-color: #d4edda;
            color: #155724;
        }
        .status-unavailable {
            background-color: #f8d7da;
            color: #721c24;
        }
        .actions a, .actions button {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
            transition: color 0.3s ease;
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            font-size: 1em;
        }
        .actions a:hover {
            color: #0056b3;
        }
        .actions button {
            color: #dc3545;
        }
        .actions button:hover {
            color: #c82333;
        }
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination a, .pagination span {
            display: inline-block;
            padding: 8px 12px;
            margin: 0 4px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-decoration: none;
            color: #007bff;
            transition: background-color 0.3s ease;
        }
        .pagination a:hover {
            background-color: #f2f2f2;
        }
        .pagination .active span {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        .pagination .disabled span {
            color: #ccc;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Admin Menu Items</h1>

        @if (session('success'))
            <div class="alert success">
                {{ session('success') }}
            </div>
        @endif

        <div class="button-group">
            <a href="{{ route('admin.menu_items.create') }}">Add New Menu Item</a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Price</th>
                    <th>Available</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($menuItems as $item)
                    <tr>
                        <td>
                            @if ($item->image_url)
                                <img src="{{ $item->image_url }}" alt="{{ $item->name }}" class="item-image">
                            @endif
                            <span class="item-name">{{ $item->name }}</span>
                        </td>
                        <td>
                            <span class="capitalize">{{ $item->type }}</span>
                        </td>
                        <td>
                            Rp {{ number_format($item->price, 0, ',', '.') }}
                        </td>
                        <td>
                            <span class="status-badge {{ $item->is_available ? 'status-available' : 'status-unavailable' }}">
                                {{ $item->is_available ? 'Yes' : 'No' }}
                            </span>
                        </td>
                        <td class="actions">
                            <a href="{{ route('admin.menu_items.edit', $item->id) }}">Edit</a>
                            <form action="{{ route('admin.menu_items.destroy', $item->id) }}" method="POST" style="display:inline-block;">
                                @csrf
                                @method('DELETE')
                                <button type="submit" onclick="return confirm('Are you sure you want to delete this item?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="text-align:center; color:#888;">
                            No menu items found.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        <div class="pagination">
            {{ $menuItems->links('pagination::bootstrap-4') }} {{-- Using Laravel's default Bootstrap pagination for simple styling --}}
        </div>
    </div>
</body>
</html>