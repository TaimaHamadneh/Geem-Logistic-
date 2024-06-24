import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:welecome_login_out/approved.dart';

class ReusableDropdown extends StatefulWidget {
  final List<String> items;
  final ValueNotifier<String?> valueListenable;
  final Function(String?) onChanged;
  final Icon icon;
  final String hintText;

  ReusableDropdown({
    required this.items,
    required this.valueListenable,
    required this.onChanged,
    required this.icon,
    this.hintText = 'Select Item', required TextStyle hintStyle,
  });

  @override
  _ReusableDropdownState createState() => _ReusableDropdownState();
}

class _ReusableDropdownState extends State<ReusableDropdown> {
  
  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        DropdownButtonHideUnderline(
          
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Row(
              children: [
                widget.icon,
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.hintText,
                    style:  TextStyle(
                      fontSize: isDesktop? 20:14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: widget.items
                .map((String item) => DropdownItem<String>(
                      value: item,
                      height: isDesktop? 50 : 40,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            valueListenable: widget.valueListenable,
            onChanged: widget.onChanged,
            buttonStyleData: ButtonStyleData(
              height:isDesktop? 60: 50,
              width:isDesktop? 210: 160,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Approved.PrimaryColor,
              ),
              elevation: 2,
            ),
            iconStyleData:  IconStyleData(
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
              ),
              iconSize: isDesktop? 20:14,
              iconEnabledColor: Colors.white,
              iconDisabledColor: Colors.grey,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Approved.PrimaryColor,
              ),
              offset: const Offset(-20, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.only(left: 14, right: 14),
            ),
          ),
        ),
        Text(
          widget.valueListenable.value ?? 'No item selected',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Approved.LightColor,
          ),
        ),
      ],
    );
  }
}
