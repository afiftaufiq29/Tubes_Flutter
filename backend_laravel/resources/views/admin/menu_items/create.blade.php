<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create New Menu Item</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 600px;
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
        .alert.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert.error ul {
            margin: 0;
            padding-left: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
        }
        .form-group input[type="text"],
        .form-group input[type="number"],
        .form-group input[type="file"],
        .form-group textarea,
        .form-group select {
            width: calc(100% - 22px); /* Account for padding and border */
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1em;
        }
        .form-group textarea {
            resize: vertical;
        }
        .checkbox-group {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .checkbox-group input[type="checkbox"] {
            margin-right: 10px;
            transform: scale(1.2);
        }
        .form-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .form-actions button {
            background-color: #ff8c00;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .form-actions button:hover {
            background-color: #e07b00;
        }
        .form-actions a {
            color: #007bff;
            text-decoration: none;
            font-weight: bold;
            font-size: 0.9em;
            transition: color 0.3s ease;
        }
        .form-actions a:hover {
            color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Create New Menu Item</h1>

        @if ($errors->any())
            <div class="alert error">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('admin.menu_items.store') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" name="name" id="name" value="{{ old('name') }}" required>
            </div>
            <div class="form-group">
                <label for="description">Description:</label>
                <textarea name="description" id="description" rows="4">{{ old('description') }}</textarea>
            </div>
            <div class="form-group">
                <label for="price">Price:</label>
                <input type="number" step="0.01" name="price" id="price" value="{{ old('price') }}" required>
            </div>
            <div class="form-group">
                <label for="image">Image:</label>
                <input type="file" name="image" id="image">
            </div>
            <div class="form-group">
                <label for="type">Type:</label>
                <select name="type" id="type" required>
                    <option value="food" {{ old('type') == 'food' ? 'selected' : '' }}>Food</option>
                    <option value="drink" {{ old('type') == 'drink' ? 'selected' : '' }}>Drink</option>
                </select>
            </div>
            <div class="checkbox-group">
                <input type="checkbox" name="is_available" id="is_available" {{ old('is_available', true) ? 'checked' : '' }}>
                <label for="is_available">Is Available</label>
            </div>
            <div class="form-group">
                <label for="rating">Rating (0-5):</label>
                <input type="number" step="0.1" name="rating" id="rating" value="{{ old('rating', 4.0) }}" min="0" max="5">
            </div>
            <div class="form-actions">
                <button type="submit">Add Menu Item</button>
                <a href="{{ route('admin.menu_items.index') }}">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>