import 'package:flutter/material.dart';

import '../../domain/entities/inventory_item.dart';

class UpdateStockDialog extends StatefulWidget {
  final InventoryItem inventoryItem;
  final Function(int newStock, String reason) onStockUpdated;

  const UpdateStockDialog({super.key, required this.inventoryItem, required this.onStockUpdated});

  @override
  State<UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<UpdateStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stockController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController.text = widget.inventoryItem.stock.toString();
  }

  @override
  void dispose() {
    _stockController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar Stock'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del producto
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: widget.inventoryItem.product.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.inventoryItem.product.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: widget.inventoryItem.product.imageUrl.isEmpty ? Colors.grey[300] : null,
                      ),
                      child: widget.inventoryItem.product.imageUrl.isEmpty
                          ? const Center(child: Icon(Icons.image, size: 20, color: Colors.grey))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.inventoryItem.product.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stock actual: ${widget.inventoryItem.stock}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo de stock
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nuevo Stock',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nuevo stock';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Por favor ingresa un número válido (0 o mayor)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de razón
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Razón del cambio',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Reposición de stock, venta, etc.',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la razón del cambio';
                  }
                  if (value.length < 3) {
                    return 'La razón debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stock mínimo: ${widget.inventoryItem.minStock}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateStock,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Actualizar'),
        ),
      ],
    );
  }

  void _updateStock() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newStock = int.parse(_stockController.text);
      final reason = _reasonController.text.trim();

      widget.onStockUpdated(newStock, reason);
      Navigator.of(context).pop();
    }
  }
}
