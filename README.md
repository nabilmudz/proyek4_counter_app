# 1
## Self Reflection

Sesi pertama dari proyek 4 adalah melakukan setup flutter dan membuat simple app untuk counter.

### Fondasi dan Setup
Saya melakukan setup flutter dengan manual (mendownload zip file), dibandingkan package seperti android studio dan lainnya. Saya juga melakukan setup dan konfigurasi dengan mengikuti arahan modul dan dibantu dengan AI dalam solving conflict seperti version, adb missing, path yang tidak sesuai. Lalu sebelumnya saya melakukan setup emulator di PC tetapi ternyata dengan RAM yang cukup terbatas. Setelah mencari cara saya menemukan alternatif dari teman saya yaitu melakukan wireless debugging dengan koneksi wifi sehingga developing android bisa dilakukan dengan optimal.

### Prinsip SRP
SRP merupakan singkatan dari Single Responsibility Principle yang dimana membuat satu file atau modul hanya memiliki satu fungsi atau tanggung jawab. Dalam implementasinya kali ini SRP digunakan dalam memisahkan logic (controller) dan tampilan (view). Dimana setiap kali data berubah dari controller, view hanya menampilkannya secara realtime menggunakan setState. Dalam melakukan tugas ini saya dibantu dengan AI guna untuk memperkenalkan konsep, behavior dari flutter serta brainstorming bagaimana best practice dalam melakukan prinsip SRP ini.

# Flutter Emulator
Pakai Powershell Run:
`flutter emulators --launch pixel6_api34 and flutter run`



