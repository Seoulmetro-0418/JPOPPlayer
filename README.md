# JPOPPlayer 🎧🇯🇵

<div>
  <button onclick="showLang('korean')">🇰🇷 한국어</button> | 
  <button onclick="showLang('chinese')">🇨🇳 中文</button> | 
  <button onclick="showLang('english')">🇺🇸 English</button> | 
  <button onclick="showLang('japanese')">🇯🇵 日本語</button>
</div>

<script>
function showLang(lang) {
  const langs = document.querySelectorAll('.lang-block');
  langs.forEach(div => div.style.display = 'none');
  document.getElementById(lang).style.display = 'block';
}
window.onload = () => {
  showLang('korean'); // 초기 표시 언어 선택
};
</script>

<div id="korean" class="lang-block" style="display:none;">
## 🇰🇷 한국어

### JPOPPlayer 소개

        JPOPPlayer는 J-POP 팬과 일본어 학습자를 위한 음악 플레이어입니다.  
        내장된 가사 타임라인을 통해 노래를 들으며 실시간으로 가사를 따라갈 수 있어,  
        즐거운 감상과 함께 자연스러운 일본어 학습이 가능합니다.

### 주요 기능

        ⏱️ **가사 타임라인**: 재생 시간에 맞춰 가사가 표시됩니다.  
        📝 **사용자 정의 가사**: 원하는 버전으로 가사를 직접 추가/편집할 수 있습니다.  
        📁 **로컬 음악 지원**: 기기에 저장된 음악 파일 재생 가능  
        📌 **즐겨찾기 및 재생목록 기능**  
        🇯🇵 **일본어 학습 친화적**: J-POP을 통해 자연스럽게 일본어를 익힐 수 있습니다.

### 개발 목적

        단순히 음악을 재생하는 앱을 넘어,  
        좋아하는 노래를 통해 일본어를 학습할 수 있도록 돕는 것이 목표입니다.

### 향후 계획

        🌐 온라인 가사 자동 불러오기

### 참고 사항

        예시로 제공된 노래 정보는 자유롭게 변경 가능합니다.  
        Excel 및 Swift 파일에 가사 예시가 포함되어 있습니다.  
        라이트/다크 모드를 모두 지원합니다.  
        음악 파일은 저작권 문제로 포함되어 있지 않으니 직접 추가해 주세요.
</div>

<div id="chinese" class="lang-block" style="display:none;">
## 🇨🇳 中文

### JPOPPlayer 介绍

        JPOPPlayer 是专为 J-POP 爱好者和日语学习者设计的音乐播放器。  
        通过内置歌词时间轴，可以边听边看歌词，提升语言学习的沉浸感与趣味性。

### 主要功能

        ⏱️ **歌词时间轴**：与播放时间同步，方便跟唱。  
        📝 **自定义歌词**：可手动添加或编辑歌词内容。  
        📁 **本地音乐支持**：播放设备上的音频文件。  
        📌 **收藏与播放列表功能**  
        🇯🇵 **适合日语学习**：通过听歌练习日语，非常实用。

### 应用目的

        不仅是音乐播放器，  
        也是帮助用户通过喜欢的歌曲自然学习日语的工具。

### 开发计划

        🌐 自动从网上获取歌词功能

### 备注

        示例歌曲信息可自行替换。  
        提供 Excel 和 Swift 文件中的歌词示例。  
        支持浅色与深色模式。  
        音乐文件因版权问题未包含，请自行添加。
</div>

<div id="english" class="lang-block" style="display:none;">
## 🇺🇸 English

### About JPOPPlayer

        JPOPPlayer is a music player specially designed for J-POP fans and Japanese learners.  
        With a built-in lyric timeline, you can follow the lyrics in real-time as the song plays,  
        making it a fun and immersive way to enjoy music and study Japanese.

### Features

        ⏱️ **Lyric Timeline**: Syncs lyrics with playback time.  
        📝 **Customizable Lyrics**: Manually add or edit lyrics.  
        📁 **Local Music Support**: Play audio files on your device.  
        📌 **Favorites and playlist support**  
        🇯🇵 **Language Learning Friendly**: Practice Japanese through music.

### Purpose

        JPOPPlayer aims to go beyond music playback,  
        helping users learn Japanese naturally through their favorite J-POP songs.

### Roadmap

        🌐 Automatic online lyric fetching

### Reference

        Feel free to replace the example song data.  
        Sample lyrics are provided in Excel and Swift files.  
        Supports both light and dark modes.  
        Music files are not included due to copyright.
</div>

<div id="japanese" class="lang-block" style="display:none;">
## 🇯🇵 日本語

### JPOPPlayerについて

        JPOPPlayerは、J-POPファンや日本語学習者のために設計された音楽プレイヤーです。  
        内蔵の歌詞タイムラインにより、曲の再生に合わせてリアルタイムで歌詞を追うことができ、  
        音楽を楽しみながら自然に日本語を学習できます。

### 特徴

        ⏱️ **歌詞タイムライン**：再生時間と同期して歌詞を表示  
        📝 **カスタマイズ可能な歌詞**：手動で歌詞を追加・編集可能  
        📁 **ローカル音楽対応**：デバイスに保存された音楽ファイルを再生  
        📌 **お気に入りとプレイリスト機能**  
        🇯🇵 **日本語学習に最適**：音楽を通して日本語を練習可能

### 目的

        ただの音楽プレイヤーにとどまらず、  
        お気に入りのJ-POPを通じて自然に日本語を学べるツールを目指しています。

### 今後の予定

        🌐 オンラインからの歌詞自動取得機能

### 注意事項

        楽曲情報は自由に変更してください（すべて例です）。  
        歌詞の例はExcelおよびSwiftファイルに含まれています。  
        ライトモード／ダークモードの両方に対応しています。  
        著作権の関係で音楽ファイルは含まれていません。ご自身で追加してください。
</div>
