import 'package:flutter/material.dart';

enum RentalStatus { ongoing, completed, expired }

class RentedTool {
	final String id;
	final String name;
	final String totalPrice;
	final String fromDate;
	// changed to be mutable so we can update the end date at runtime
	String toDate;
	// changed to be mutable so we can update status (returned/completed)
	RentalStatus status;

	RentedTool({
		required this.id,
		required this.name,
		required this.totalPrice,
		required this.fromDate,
		required this.toDate,
		required this.status,
	});
}

class RentedToolsPage extends StatefulWidget {
	const RentedToolsPage({Key? key}) : super(key: key);

	@override
	State<RentedToolsPage> createState() => _RentedToolsPageState();
}

class _RentedToolsPageState extends State<RentedToolsPage> {
	final List<RentedTool> _items = [
		RentedTool(id: '1', name: 'Electric Drill', totalPrice: 'YER 2,500', fromDate: '2025-12-01', toDate: '2025-12-05', status: RentalStatus.ongoing),
		RentedTool(id: '2', name: 'Lawn Mower', totalPrice: 'YER 3,000', fromDate: '2025-11-10', toDate: '2025-11-12', status: RentalStatus.completed),
		RentedTool(id: '3', name: 'Circular Saw', totalPrice: 'YER 1,800', fromDate: '2025-10-01', toDate: '2025-10-03', status: RentalStatus.expired),
		RentedTool(id: '4', name: 'Extension Ladder', totalPrice: 'YER 1,200', fromDate: '2025-12-20', toDate: '2026-01-02', status: RentalStatus.ongoing),
	];

	void _showMessage(String text) {
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
	}

	Color _statusColor(RentalStatus s) {
		switch (s) {
			case RentalStatus.ongoing:
				return const Color(0xFFFFA726); // orange
			case RentalStatus.completed:
				return Colors.green.shade700;
			case RentalStatus.expired:
				return Colors.red.shade600;
		}
	}

	String _statusText(RentalStatus s) {
		switch (s) {
			case RentalStatus.ongoing:
				return 'Ongoing';
			case RentalStatus.completed:
				return 'Completed';
			case RentalStatus.expired:
				return 'Expired';
		}
	}

	Widget _buildStatusBadge(RentalStatus s) {
		final color = _statusColor(s);
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
			decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))]),
			child: Text(_statusText(s), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
		);
	}

	// Consistent modern button styles used across the page
	Widget _primaryButton(String label, VoidCallback onPressed, {double? width, bool full = false}) {
		return SizedBox(
			width: width ?? (full ? double.infinity : null),
			child: ElevatedButton(
				onPressed: onPressed,
				style: ElevatedButton.styleFrom(
					backgroundColor: const Color(0xFFFFC72C),
					foregroundColor: Colors.black,
					elevation: 2,
					padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
					minimumSize: const Size(64, 44),
				),
				child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
			),
		);
	}

	Widget _outlineDangerButton(String label, VoidCallback onPressed, {double? width, bool full = false}) {
		return SizedBox(
			width: width ?? (full ? double.infinity : null),
			child: OutlinedButton(
				onPressed: onPressed,
				style: OutlinedButton.styleFrom(
					foregroundColor: Colors.red.shade700,
					side: BorderSide(color: Colors.red.shade200),
					padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
					minimumSize: const Size(64, 44),
				),
				child: Text(label, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
			),
		);
	}

	Widget _buildCard(RentedTool t, BoxConstraints bc) {
		final isWide = bc.maxWidth > 600;
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 8),
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: const Color(0xFFFFF8E1),
				borderRadius: BorderRadius.circular(12),
				boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
			),
			child: isWide
					? Row(
							children: [
								// Image placeholder
								Container(
									width: 88,
									height: 88,
									decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
									child: const Icon(Icons.build, size: 42, color: Colors.grey),
								),
								const SizedBox(width: 12),
								// Details
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
											const SizedBox(height: 6),
											Text('Total: ${t.totalPrice}', style: TextStyle(color: Colors.grey.shade700)),
											const SizedBox(height: 6),
											Text('Period: ${t.fromDate}  •  ${t.toDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
										],
									),
								),
								const SizedBox(width: 8),
								Column(
									crossAxisAlignment: CrossAxisAlignment.end,
									children: [
										_buildStatusBadge(t.status),
										const SizedBox(height: 10),
										if (t.status == RentalStatus.completed)
											_primaryButton('Rate Owner', () => _rateOwner(t), width: 140)
										else if (t.status == RentalStatus.ongoing)
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													_primaryButton('Extend', () => _extendRental(t)),
													const SizedBox(width: 8),
													_outlineDangerButton('Return', () => _confirmReturn(t)),
												],
											)
										else
											SizedBox(width: 140, child: Text(''))
									],
								)
							],
						)
					: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Container(
											width: 64,
											height: 64,
											decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
											child: const Icon(Icons.build, size: 36, color: Colors.grey),
										),
										const SizedBox(width: 12),
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
													const SizedBox(height: 6),
													Text('Total: ${t.totalPrice}', style: TextStyle(color: Colors.grey.shade700)),
												],
											),
										),
										const SizedBox(width: 8),
										_buildStatusBadge(t.status),
									],
								),
								const SizedBox(height: 10),
								Text('Period: ${t.fromDate}  •  ${t.toDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
								const SizedBox(height: 10),
								if (t.status == RentalStatus.completed)
									_primaryButton('Rate Owner', () => _rateOwner(t), full: true)
								else if (t.status == RentalStatus.ongoing)
									Row(
										children: [
											Expanded(child: _primaryButton('Extend Rental', () => _extendRental(t), full: true)),
											const SizedBox(width: 10),
											Expanded(child: _outlineDangerButton('Return Tool', () => _confirmReturn(t), full: true)),
										],
									)
								else
									const SizedBox.shrink(),
							],
						),
		);
	}

	// New: open bottom sheet with calendar picker starting from current end date and Confirm button
	Future<void> _extendRental(RentedTool t) async {
		DateTime currentEnd;
		try {
			currentEnd = DateTime.parse(t.toDate);
		} catch (_) {
			currentEnd = DateTime.now();
		}
		DateTime selected = currentEnd;
		await showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
			builder: (ctx) {
				return Padding(
					padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
					child: StatefulBuilder(builder: (c, setLocal) {
						return Padding(
							padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
									const SizedBox(height: 12),
									const Text('Select new end date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
									const SizedBox(height: 12),
									// CalendarDatePicker so the date picker is embedded and we can add a confirm button below
									CalendarDatePicker(
										initialDate: selected,
										firstDate: currentEnd,
										lastDate: currentEnd.add(const Duration(days: 365)),
										onDateChanged: (d) => setLocal(() => selected = d),
									),
									const SizedBox(height: 12),
									_primaryButton('Confirm', () {
										setState(() {
											t.toDate = selected.toIso8601String().split('T')[0];
										});
										Navigator.of(ctx).pop();
										_showMessage('Extended ${t.name} until ${t.toDate}');
									}),
								],
							),
						);
					}),
				);
			},
		);
	}

	// New: return confirmation dialog
	Future<void> _confirmReturn(RentedTool t) async {
		final res = await showDialog<bool>(
			context: context,
			builder: (ctx) => AlertDialog(
				title: const Text('Return Tool'),
				content: const Text('Are you sure you want to return this tool?'),
				actions: [
					TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
					TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
				],
			),
		);
		if (res == true) {
			setState(() {
				// mark returned tools as completed
				t.status = RentalStatus.completed;
			});
			_showMessage('Returned ${t.name}');
		}
	}

	// New: rating bottom sheet with stars + optional comment + submit
	Future<void> _rateOwner(RentedTool t) async {
		int rating = 5;
		final TextEditingController commentCtrl = TextEditingController();
		await showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
			builder: (ctx) {
				return Padding(
					padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
					child: StatefulBuilder(builder: (c, setLocal) {
						return Padding(
							padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
									const SizedBox(height: 12),
									const Text('Rate Owner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
									const SizedBox(height: 12),
									Row(
										children: List.generate(5, (i) {
											final idx = i + 1;
											return IconButton(
												onPressed: () => setLocal(() => rating = idx),
												icon: Icon(idx <= rating ? Icons.star : Icons.star_border, color: const Color(0xFFFFC72C)),
											);
										}),
									),
									const SizedBox(height: 8),
									TextField(
										controller: commentCtrl,
										maxLines: 3,
										decoration: InputDecoration(hintText: 'Optional comment', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
									),
									const SizedBox(height: 12),
									_primaryButton('Submit Rating', () {
										// Here you would normally send rating + comment to backend
										Navigator.of(ctx).pop();
										_showMessage('Submitted rating ($rating) for ${t.name}');
									}),
								],
							),
						);
					}),
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.white,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(20.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Row(
										children: [
											IconButton(
												icon: const Icon(Icons.chevron_left_rounded),
												onPressed: () => Navigator.of(context).maybePop(),
											),
											const SizedBox(width: 4),
											const Text('Rented Tools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
										],
									),
								],
							),
							const SizedBox(height: 12),
							Expanded(
								child: LayoutBuilder(builder: (context, bc) {
									return _items.isEmpty
											? const Center(child: Text('No rented tools', style: TextStyle(fontSize: 16)))
											: ListView.separated(
													padding: const EdgeInsets.only(top: 8, bottom: 24),
													itemCount: _items.length,
													separatorBuilder: (_, __) => const SizedBox(height: 8),
													itemBuilder: (context, idx) {
														// We must pass the updated callbacks into the card builder. To avoid repeating the entire card,
														// we'll intercept the button callbacks by rebuilding the card here with the same UI but connected handlers.
														final t = _items[idx];
														return Container(
															margin: const EdgeInsets.symmetric(vertical: 8),
															padding: const EdgeInsets.all(12),
															decoration: BoxDecoration(
																color: const Color(0xFFFFF8E1),
																borderRadius: BorderRadius.circular(12),
																boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
															),
															child: bc.maxWidth > 600
																? Row(
																		children: [
																			// Image placeholder
																			Container(
																				width: 88,
																				height: 88,
																				decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
																				child: const Icon(Icons.build, size: 42, color: Colors.grey),
																			),
																			const SizedBox(width: 12),
																			// Details
																			Expanded(
																				child: Column(
																					crossAxisAlignment: CrossAxisAlignment.start,
																					children: [
																						Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
																						const SizedBox(height: 6),
																						Text('Total: ${t.totalPrice}', style: TextStyle(color: Colors.grey.shade700)),
																						const SizedBox(height: 6),
																						Text('Period: ${t.fromDate}  •  ${t.toDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
																					],
																				),
																			),
																			const SizedBox(width: 8),
																			Column(
																				crossAxisAlignment: CrossAxisAlignment.end,
																				children: [
																					_buildStatusBadge(t.status),
																					const SizedBox(height: 10),
																					if (t.status == RentalStatus.completed)
																						_primaryButton('Rate Owner', () => _rateOwner(t), width: 140)
																					else if (t.status == RentalStatus.ongoing)
																						Row(
																							mainAxisSize: MainAxisSize.min,
																							children: [
																								_primaryButton('Extend', () => _extendRental(t)),
																								const SizedBox(width: 8),
																								_outlineDangerButton('Return', () => _confirmReturn(t)),
																							],
																						)
																					else
																						SizedBox(width: 140, child: Text(''))
																				],
																			)
																		],
																  )
																: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Row(
																				children: [
																					Container(
																						width: 64,
																						height: 64,
																						decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
																						child: const Icon(Icons.build, size: 36, color: Colors.grey),
																					),
																					const SizedBox(width: 12),
																					Expanded(
																						child: Column(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
																								const SizedBox(height: 6),
																								Text('Total: ${t.totalPrice}', style: TextStyle(color: Colors.grey.shade700)),
																							],
																						),
																					),
																					const SizedBox(width: 8),
																					_buildStatusBadge(t.status),
																				],
																			),
																			const SizedBox(height: 10),
																			Text('Period: ${t.fromDate}  •  ${t.toDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
																			const SizedBox(height: 10),
																			if (t.status == RentalStatus.completed)
																				_primaryButton('Rate Owner', () => _rateOwner(t), full: true)
																			else if (t.status == RentalStatus.ongoing)
																				Row(
																					children: [
																						Expanded(child: _primaryButton('Extend Rental', () => _extendRental(t), full: true)),
																						const SizedBox(width: 10),
																						Expanded(child: _outlineDangerButton('Return Tool', () => _confirmReturn(t), full: true)),
																					],
																				)
																			else
																				const SizedBox.shrink(),
																		],
																  ),
														);
													},
												);
								}),
							),
						],
					),
				),
			),
		);
	}
}

// small helper to preview the page standalone when running this file directly
void main() {
	runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: RentedToolsPage()));
}

