import 'package:flutter/material.dart';
import 'package:patogh/data/iran_locations.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/theme/patogh_theme.dart';

class IranLocationPickerPage extends StatefulWidget {
  final String initialProvince;
  final String initialCity;
  final String title;

  const IranLocationPickerPage({
    super.key,
    this.initialProvince = 'خراسان رضوی',
    this.initialCity = 'مشهد',
    this.title = 'انتخاب استان و شهر',
  });

  @override
  State<IranLocationPickerPage> createState() => _IranLocationPickerPageState();
}

class _IranLocationPickerPageState extends State<IranLocationPickerPage> {
  late String province;
  late String city;
  String query = '';

  @override
  void initState() {
    super.initState();
    province = IranLocations.byProvince.containsKey(widget.initialProvince)
        ? widget.initialProvince
        : IranLocations.provinces.first;
    final cities = IranLocations.citiesFor(province);
    city = cities.contains(widget.initialCity)
        ? widget.initialCity
        : cities.first;
  }

  @override
  Widget build(BuildContext context) {
    final cities = IranLocations.citiesFor(province)
        .where((item) => query.isEmpty || item.contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<String>(
            initialValue: province,
            isExpanded: true,
            items: IranLocations.provinces
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                province = value;
                city = IranLocations.citiesFor(province).first;
                query = '';
              });
            },
            decoration: const InputDecoration(
              labelText: 'استان',
              prefixIcon: Icon(Icons.map_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: const InputDecoration(
              labelText: 'جستجوی شهر',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '$province • ${IranLocations.citiesFor(province).length} شهر/مرکز شهری در کاتالوگ آفلاین',
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
            ),
          ),
          const SizedBox(height: 10),
          ...cities.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: item == city
                    ? const Color(0xFF2A2119)
                    : const Color(0xFF171717),
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  onTap: () => setState(() => city = item),
                  leading: Icon(
                    item == city
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: item == city
                        ? PatoghTheme.orange
                        : const Color(0xFF777777),
                  ),
                  title: Text(item),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(context)
                    .pop(LocationChoice(province: province, city: city)),
            icon: const Icon(Icons.check_rounded),
            label: Text('انتخاب $city'),
          ),
        ],
      ),
    );
  }
}
