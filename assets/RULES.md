# Kelime Oyunu — Kurallar

## Genel

1. Oyun, verilen kategori ve tanıma uygun kelimeyi harf harf tahmin etme üzerine kuruludur.
2. Amaç, belirlenen süre içinde veya hata yapmadan kelimeyi tamamen bulmaktır.
3. Tüm tahminler ekrandaki klavye üzerinden yapılır; fiziksel klavye devre dışıdır.

## Level Sistemi

1. Oyun, basitten zora doğru ilerleyen seviyelerden oluşur: **Kolay** → **Orta** → **Zor**.
2. Her seviye, kelime uzunluğu ve kelime sayısı açısından daha zorlaşır.
3. Yeni bir level, bir önceki level başarıyla tamamlanarak açılır.
4. Başarılı geçen her level, sonraki seviyeyi otomatik olarak açar.

## Oynanış

1. Her level bir **kategor**i ve bir **soru/tanım** sunar.
2. Cevap kelimesi, alt satırda eşit sayıda **harf kutusu** olarak gösterilir (her kutu bir harftir).
3. Kullanıcı, ekrandaki klavyeden bir harf seçer.
   - **Doğru harf:** Kelimenin tüm görünümlerinde ilgili kutular açılır ve puan kazanılır.
   - **Yanlış harf:** Joker kullanılmaz; kalan "can" sayısından 1 düşülür.
4. Kelimenin tüm harfleri açıldığında level **tamamlanmış** sayılır.
5. Can sayısı sıfıra düşerse oyun **biter**.

## Joker Hakları

Her levelde **3 joker hakkı** bulunur:

| Joker | Etki |
|-------|------|
| **Joker 1 — İpucu Harfi** | Rastgele 1 doğru harfi açar. |
| **Joker 2 — Yanlış Temizle** | Ekrandaki en fazla 3 yanlış harfi kaldırır. |
| **Joker 3 — Puan Çarpanı** | O leveldeki mevcut puanı 2'ye çarpar. |

- Jokerler bir kere kullanıldığında o level için tekrar kullanılamaz.
- Kalan joker sayısına göre oyun sonunda bonus puan eklenir.

## Puanlama

1. Her seviyenin bir **baz puanı** vardır; zorlaştıkça baz puan artar.
2. Seviye zorluk katsayısı, ilerledikçe puanları artırır.
3. Her joker kullanımından sabit bir ceza puanı düşülür.
4. Doğru tamamlanan levelde kalan jokerler için bonus puan verilir.

```
finalScore = (basePoints * difficultyMultiplier) + timeBonus
             - (jokersUsed * 5) + (remainingJokers * 10)
```

## Kayıtlar

1. Tüm oyun kayıtları Firebase Auth hesabıyla eşleşen kullanıcıya ait olarak Firestore'da saklanır.
2. Her kaydın içeriği: tamamlanan level, tahmin edilen kelime, kazanılan puan, kullanılan jokerler, oyun süresi ve sonucu.
3. Kullanıcı profilinde toplam puan, tamamlanan level sayısı ve oynanan oyun sayısı görüntülenir.

## Güvenlik ve Davranış

1. Kullanıcılar birbirine saygılı olmalıdır.
2. Hile, bot veya otomatik giriş araçları kullanılamaz.
3. Kurallar geliştirme ekibi tarafından güncellenebilir; değişiklikler uygulamada bildirilir.
