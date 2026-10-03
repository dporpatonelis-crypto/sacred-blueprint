import { useEffect, useMemo, useRef, useState } from "react";
import { Upload, Trash2, ChevronDown, FileText, Headphones, Presentation, FileType, ExternalLink, X, Download, Puzzle, Play, Bookmark, Star } from "lucide-react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import SettingsPanel from "@/components/SettingsPanel";
import { useLanguage } from "@/contexts/LanguageContext";

// ---------- Types ----------
type TabKey = "audio" | "slides" | "pdf" | "text";

interface AudioItem {
  title: string; subtitle?: string; description?: string; date?: string;
  audioUrl?: string; isNLM?: boolean; nlmUrl?: string;
}
interface SlideItem { title: string; subtitle?: string; description?: string; date?: string; embedUrl?: string; directUrl?: string; }
interface PdfItem { title: string; subtitle?: string; description?: string; date?: string; pdfUrl?: string; viewerUrl?: string; }
interface TextItem { title: string; subtitle?: string; description?: string; date?: string; type?: string; content: string; }
type MediaItem = AudioItem | SlideItem | PdfItem | TextItem;
type CurationBucket = "current" | "selected";

interface CuratedMedia {
  id: string;
  lessonId: string;
  lessonTitle: string;
  tab: TabKey;
  index: number;
  item: MediaItem;
}

interface MediaCurations {
  current: CuratedMedia[];
  selected: CuratedMedia[];
}

interface Lesson {
  id: string;
  title: string;
  description: string;
  accent: string;
  media: { audio: AudioItem[]; slides: SlideItem[]; pdf: PdfItem[]; text: TextItem[] };
  remote?: boolean;
}

const STORAGE_KEY = "media-library-lessons-v1";
const CURATIONS_KEY = "media-library-curations-v1";
const PUZZLES_KEY = "media-library-puzzles-v1";
const ACCENTS = ["#c9a84c", "#8296b0", "#a3c585", "#c17c74", "#9b72cf", "#e8a87c"];
const PUBLIC_BASE_URL = import.meta.env.BASE_URL;

// ---------- Puzzle types ----------
interface PuzzleScenario {
  id: string;
  title: string;
  pairs: number;
  scenario: any; // raw JSON for the GLB matcher
  addedAt: number;
  builtin?: boolean;
  remote?: boolean;
}

const DEFAULT_PUZZLE: PuzzleScenario = {
  id: "builtin_agora",
  title: "Αρχαία Αγορά Αθηνών",
  pairs: 6,
  scenario: null, // null => puzzle loads its own initDemo
  addedAt: 0,
  builtin: true,
};

// ---------- Notebook JSON -> Lessons ----------
function convertNotebookToLessons(data: any): Lesson[] {
  if (!data?.chapters || !Array.isArray(data.chapters)) {
    throw new Error("Invalid notebook JSON: missing 'chapters' array.");
  }
  const notebookTitle = data.title || "Notebook";
  return data.chapters.map((ch: any, idx: number): Lesson => {
    const title = ch.title || `Chapter ${idx + 1}`;
    let description: string = (ch.text || "").substring(0, 200);
    if (!description && ch.html) description = String(ch.html).replace(/<[^>]*>/g, "").substring(0, 200);
    if (!description) description = `From notebook: ${notebookTitle}`;

    const media: Lesson["media"] = { audio: [], slides: [], pdf: [], text: [] };

    if (ch.html?.trim()) {
      media.text.push({ title: `${title} – Notes`, subtitle: "From notebook", type: "Notes", description: "", content: ch.html });
    } else if (ch.text?.trim()) {
      media.text.push({ title: `${title} – Notes`, subtitle: "From notebook", type: "Notes", description: "", content: `<p>${String(ch.text).replace(/</g, "&lt;").replace(/\n/g, "<br>")}</p>` });
    }

    if (Array.isArray(ch.stickies)) {
      ch.stickies.forEach((sticky: string, si: number) => {
        media.text.push({
          title: `${title} – Sticky ${si + 1}`, subtitle: "Sticky", type: "Sticky note", description: "",
          content: `<div style="background:#fff2cc;padding:12px;border-left:4px solid #c9a84c;">${String(sticky).replace(/</g, "&lt;")}</div>`,
        });
      });
    }

    const ms = ch.media;
    if (ms && typeof ms === "object") {
      (ms.audio || []).forEach((a: any) => {
        if (!a.url) return;
        const normalizedUrl = String(a.url).toLowerCase();
        const isNLM = normalizedUrl.startsWith("https://notebooklm.link.google/") || normalizedUrl.startsWith("http://notebooklm.link.google/") || normalizedUrl.startsWith("https://www.notebooklm.link.google/");
        const common = { title: a.label || (isNLM ? "NotebookLM" : "Audio"), subtitle: a.notes, description: a.notes };
        media.audio.push(isNLM
          ? { ...common, isNLM: true, nlmUrl: a.url }
          : { ...common, audioUrl: a.url });
      });
      (ms.slides || []).forEach((s: any) => s.url && media.slides.push({ title: s.label || "Presentation", subtitle: s.notes, description: s.notes, embedUrl: s.url, directUrl: s.url }));
      (ms.pdf || []).forEach((p: any) => p.url && media.pdf.push({
        title: p.label || "PDF", subtitle: p.notes, description: p.notes, pdfUrl: p.url,
        viewerUrl: `https://docs.google.com/viewer?url=${encodeURIComponent(p.url)}&embedded=true`,
      }));
      (ms.notebooklm || []).forEach((n: any) => n.url && media.audio.push({ title: n.label || "NotebookLM", subtitle: n.notes, description: n.notes, isNLM: true, nlmUrl: n.url }));
      (ms.text || []).forEach((tx: any) => tx.content && media.text.push({ title: tx.label || "Text note", subtitle: tx.notes, description: tx.notes, type: "Text", content: tx.content }));
    }

    return {
      id: `lesson_${Date.now()}_${idx}_${Math.random().toString(36).slice(2, 6)}`,
      title, description,
      accent: ACCENTS[idx % ACCENTS.length],
      media,
    };
  });
}

function emptyCurations(): MediaCurations {
  return { current: [], selected: [] };
}

function normalizeCurations(value: any): MediaCurations {
  const validTabs: TabKey[] = ["audio", "slides", "pdf", "text"];
  const normalizeBucket = (bucket: any): CuratedMedia[] => {
    if (!Array.isArray(bucket)) return [];
    return bucket
      .filter((entry: any) => entry && typeof entry.id === "string" && entry.item && typeof entry.item.title === "string")
      .map((entry: any): CuratedMedia => ({
        id: String(entry.id),
        lessonId: String(entry.lessonId || ""),
        lessonTitle: String(entry.lessonTitle || "Lesson"),
        tab: validTabs.includes(entry.tab) ? entry.tab : "text",
        index: typeof entry.index === "number" ? entry.index : 0,
        item: entry.item as MediaItem,
      }));
  };
  return {
    current: normalizeBucket(value?.current),
    selected: normalizeBucket(value?.selected),
  };
}

function createCuratedMedia(lesson: Lesson, tab: TabKey, index: number, item: MediaItem): CuratedMedia {
  return {
    id: lesson.id + "::" + tab + "::" + index,
    lessonId: lesson.id,
    lessonTitle: lesson.title,
    tab,
    index,
    item,
  };
}

// ---------- Page ----------
const Media = () => {
  const { tr, lang } = useLanguage();
  const [lessons, setLessons] = useState<Lesson[]>(() => {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]"); } catch { return []; }
  });
  const [remoteLessons, setRemoteLessons] = useState<Lesson[]>([]);
  const [expanded, setExpanded] = useState<Record<string, boolean>>({});
  const [activeTab, setActiveTab] = useState<Record<string, TabKey>>({});
  const [status, setStatus] = useState<{ type: "ok" | "err" | "info"; msg: string } | null>(null);
  const [modal, setModal] = useState<{ title: string; html: string } | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const curationFileRef = useRef<HTMLInputElement>(null);
  const [curations, setCurations] = useState<MediaCurations>(() => {
    try {
      return normalizeCurations(JSON.parse(localStorage.getItem(CURATIONS_KEY) || "{}"));
    } catch {
      return emptyCurations();
    }
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(lessons.filter(l => !l.remote)));
  }, [lessons]);

  useEffect(() => {
    localStorage.setItem(CURATIONS_KEY, JSON.stringify(curations));
  }, [curations]);

  // Load permanent lessons bundled in public/data/lessons
  useEffect(() => {
    (async () => {
      try {
        const previewUrl = new URLSearchParams(window.location.search).get("dataUrl");
        if (previewUrl) {
          const response = await fetch(previewUrl, { cache: "no-store" });
          if (!response.ok) throw new Error(`HTTP ${response.status}`);
          const data = await response.json();
          const converted = convertNotebookToLessons(data.personalpage ?? data);
          setRemoteLessons(converted.map((lesson, index) => ({ ...lesson, id: `preview_${index}`, remote: true })));
          setExpanded(Object.fromEntries(converted.map((_, index) => [`preview_${index}`, true])));
          return;
        }
        const res = await fetch(`${PUBLIC_BASE_URL}data/lessons/index.json`, { cache: "no-cache" });
        if (!res.ok) return;
        const files: string[] = await res.json();
        const out: Lesson[] = [];
        for (const f of files) {
          try {
            const r = await fetch(`${PUBLIC_BASE_URL}data/lessons/${f}`, { cache: "no-cache" });
            if (!r.ok) continue;
            const data = await r.json();
            const conv = convertNotebookToLessons(data);
            conv.forEach((l, i) => out.push({
              ...l,
              id: `remote_lesson_${f}_${i}`,
              remote: true,
            }));
          } catch (e) { console.warn("Failed to load lesson", f, e); }
        }
        setRemoteLessons(out);
      } catch (e) {
        if (new URLSearchParams(window.location.search).has("dataUrl")) {
          console.error("Personal Page preview failed:", e);
          setStatus({ type: "err", msg: "Σφάλμα φόρτωσης προεπισκόπησης." });
        }
      }
    })();
  }, []);

  const firstTab = (l: Lesson): TabKey => {
    const order: TabKey[] = ["audio", "slides", "pdf", "text"];
    return order.find(t => l.media[t]?.length > 0) || "text";
  };

  async function handleFiles(files: FileList | null) {
    if (!files?.length) return;
    setStatus({ type: "info", msg: lang === "el" ? "Φόρτωση..." : "Loading..." });
    try {
      let added = 0;
      const next: Lesson[] = [...lessons];
      for (const file of Array.from(files)) {
        const text = await file.text();
        const parsed = JSON.parse(text);
        const conv = convertNotebookToLessons(parsed);
        next.push(...conv);
        added += conv.length;
      }
      setLessons(next);
      setStatus({ type: "ok", msg: lang === "el" ? `Εισήχθησαν ${added} μαθήματα.` : `Imported ${added} lessons.` });
    } catch (e: any) {
      setStatus({ type: "err", msg: (lang === "el" ? "Σφάλμα: " : "Error: ") + e.message });
    }
    setTimeout(() => setStatus(null), 4000);
    if (fileRef.current) fileRef.current.value = "";
  }

  function removeLesson(id: string) {
    if (!confirm(lang === "el" ? "Διαγραφή μαθήματος;" : "Remove this lesson?")) return;
    setLessons(prev => prev.filter(l => l.id !== id));
  }

  function clearAll() {
    if (!lessons.length) return;
    if (!confirm(lang === "el" ? "Διαγραφή όλων των μαθημάτων;" : "Remove all lessons?")) return;
    setLessons([]);
  }

  function exportJson() {
    const blob = new Blob([JSON.stringify({ lessons }, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = "media-library.json"; a.click();
    URL.revokeObjectURL(url);
  }

  function toggleCuration(bucket: CurationBucket, lesson: Lesson, tab: TabKey, index: number, item: MediaItem) {
    const entry = createCuratedMedia(lesson, tab, index, item);
    setCurations(prev => {
      const list = prev[bucket];
      const exists = list.some(existing => existing.id === entry.id);
      return {
        ...prev,
        [bucket]: exists ? list.filter(existing => existing.id !== entry.id) : [...list, entry],
      };
    });
  }

  function removeCuration(bucket: CurationBucket, id: string) {
    setCurations(prev => ({
      ...prev,
      [bucket]: prev[bucket].filter(entry => entry.id !== id),
    }));
  }

  function clearCuration(bucket: CurationBucket) {
    if (!curations[bucket].length) return;
    const label = bucket === "current"
      ? (lang === "el" ? "του τρέχοντος μαθήματος" : "the current lesson")
      : (lang === "el" ? "των επιλεγμένων" : "the selected items");
    if (!confirm(lang === "el" ? "Να διαγραφούν οι επιλογές " + label + ";" : "Clear " + label + "?")) return;
    setCurations(prev => ({ ...prev, [bucket]: [] }));
  }

  function exportCurations() {
    const blob = new Blob([
      JSON.stringify({ version: 1, current: curations.current, selected: curations.selected }, null, 2),
    ], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = "media-curation.json"; a.click();
    URL.revokeObjectURL(url);
  }

  async function handleCurationFile(files: FileList | null) {
    if (!files?.length) return;
    try {
      const text = await files[0].text();
      const parsed = JSON.parse(text);
      const next = normalizeCurations(parsed);
      setCurations(next);
      setStatus({
        type: "ok",
        msg: lang === "el"
          ? "Οι επιλογές current lesson και Επιλεγμένα φορτώθηκαν."
          : "Current lesson and Selected items loaded.",
      });
    } catch (e: any) {
      setStatus({ type: "err", msg: (lang === "el" ? "Σφάλμα επιλογών: " : "Curation error: ") + e.message });
    }
    setTimeout(() => setStatus(null), 4000);
    if (curationFileRef.current) curationFileRef.current.value = "";
  }

  const renderCurationActions = (lesson: Lesson, tab: TabKey, index: number, item: MediaItem) => {
    const entry = createCuratedMedia(lesson, tab, index, item);
    const inCurrent = curations.current.some(existing => existing.id === entry.id);
    const inSelected = curations.selected.some(existing => existing.id === entry.id);
    return (
      <div className="flex flex-wrap gap-2 mb-3">
        <button
          type="button"
          onClick={(e) => { e.stopPropagation(); toggleCuration("current", lesson, tab, index, item); }}
          aria-pressed={inCurrent}
          className={inCurrent
            ? "inline-flex items-center gap-1 text-[10px] tracking-[0.12em] font-body uppercase border border-foreground bg-foreground text-background px-2 py-1"
            : "inline-flex items-center gap-1 text-[10px] tracking-[0.12em] font-body uppercase border border-border text-muted-foreground px-2 py-1 hover:border-foreground hover:text-foreground"}
        >
          <Bookmark className={inCurrent ? "w-3 h-3 fill-current" : "w-3 h-3"} />
          {inCurrent ? (lang === "el" ? "Στο τρέχον" : "In current") : (lang === "el" ? "Τρέχον μάθημα" : "Current lesson")}
        </button>
        <button
          type="button"
          onClick={(e) => { e.stopPropagation(); toggleCuration("selected", lesson, tab, index, item); }}
          aria-pressed={inSelected}
          className={inSelected
            ? "inline-flex items-center gap-1 text-[10px] tracking-[0.12em] font-body uppercase border border-foreground bg-foreground text-background px-2 py-1"
            : "inline-flex items-center gap-1 text-[10px] tracking-[0.12em] font-body uppercase border border-border text-muted-foreground px-2 py-1 hover:border-foreground hover:text-foreground"}
        >
          <Star className={inSelected ? "w-3 h-3 fill-current" : "w-3 h-3"} />
          {inSelected ? (lang === "el" ? "Επιλεγμένο" : "Selected") : (lang === "el" ? "Επιλεγμένα" : "Selected")}
        </button>
      </div>
    );
  };

  const renderCuratedEntry = (entry: CuratedMedia, bucket: CurationBucket) => {
    const sourceLesson = [...remoteLessons, ...lessons].find(lesson => lesson.id === entry.lessonId);
    const sourceItems = sourceLesson ? (sourceLesson.media[entry.tab] as MediaItem[]) : [];
    const liveItem = sourceItems[entry.index] || sourceItems.find(candidate => candidate.title === entry.item.title);
    const item = (liveItem || entry.item) as any;
    const sourceTitle = sourceLesson?.title || entry.lessonTitle;
    const typeLabel = entry.tab === "audio"
      ? (item.isNLM ? "NotebookLM" : "Audio")
      : entry.tab === "slides" ? "Slides"
      : entry.tab === "pdf" ? "PDF"
      : (item.type || "Text");

    return (
      <article key={bucket + "-" + entry.id} className="border border-border bg-background p-4">
        <div className="flex items-start gap-3">
          <div className="flex-1 min-w-0">
            <span className="text-[10px] tracking-[0.15em] font-body text-muted-foreground uppercase">{typeLabel}</span>
            <h3 className="font-serif text-lg italic mt-1">{item.title}</h3>
            <p className="text-[10px] tracking-[0.12em] font-body uppercase text-muted-foreground mt-1">
              {lang === "el" ? "Από" : "From"}: {sourceTitle}
            </p>
          </div>
          <button
            type="button"
            onClick={() => removeCuration(bucket, entry.id)}
            className="p-1 text-muted-foreground hover:text-destructive transition-colors"
            aria-label={lang === "el" ? "Αφαίρεση επιλογής" : "Remove selection"}
          >
            <X className="w-4 h-4" />
          </button>
        </div>
        {item.description && <p className="font-body text-sm text-muted-foreground mt-3">{item.description}</p>}
        {entry.tab === "audio" && item.audioUrl && <audio controls className="w-full mt-3" src={item.audioUrl} />}
        {entry.tab === "audio" && item.isNLM && item.nlmUrl && (
          <a href={item.nlmUrl} target="_blank" rel="noreferrer"
            className="inline-flex items-center gap-2 mt-3 text-xs tracking-[0.15em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors">
            {tr("media.open")} <ExternalLink className="w-3 h-3" />
          </a>
        )}
        {entry.tab === "slides" && (item.directUrl || item.embedUrl) && (
          <a href={item.directUrl || item.embedUrl} target="_blank" rel="noreferrer"
            className="inline-flex items-center gap-2 mt-3 text-xs tracking-[0.15em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors">
            {tr("media.open")} <ExternalLink className="w-3 h-3" />
          </a>
        )}
        {entry.tab === "pdf" && (item.pdfUrl || item.viewerUrl) && (
          <div className="flex flex-wrap gap-3 mt-3">
            <a href={item.pdfUrl || item.viewerUrl} target="_blank" rel="noreferrer"
              className="text-xs tracking-[0.15em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors">
              {tr("media.open")}
            </a>
            {item.pdfUrl && <a href={item.pdfUrl} download
              className="text-xs tracking-[0.15em] font-body border border-border px-3 py-2 hover:bg-card transition-colors">
              {tr("media.download")}
            </a>}
          </div>
        )}
        {entry.tab === "text" && (
          <button
            type="button"
            onClick={() => setModal({ title: item.title, html: item.content || "" })}
            className="inline-flex mt-3 text-xs tracking-[0.15em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors"
          >
            {tr("media.read")}
          </button>
        )}
      </article>
    );
  };

  const renderCurationBucket = (bucket: CurationBucket) => {
    const isCurrent = bucket === "current";
    const entries = curations[bucket];
    const Icon = isCurrent ? Bookmark : Star;
    const title = isCurrent
      ? (lang === "el" ? "Τρέχον μάθημα" : "Current lesson")
      : (lang === "el" ? "Επιλεγμένα" : "Selected");
    const empty = isCurrent
      ? (lang === "el" ? "Διάλεξε υλικό από οποιοδήποτε μάθημα παρακάτω." : "Choose material from any lesson below.")
      : (lang === "el" ? "Κράτησε εδώ το υλικό που θέλεις να επαναχρησιμοποιείς." : "Keep reusable, important material here.");

    return (
      <div className="border border-border bg-card/40 p-5">
        <div className="flex items-start gap-3 mb-4">
          <Icon className="w-4 h-4 mt-1 opacity-70" />
          <div className="flex-1">
            <div className="flex items-center gap-3">
              <h2 className="font-serif text-2xl italic font-light">{title}</h2>
              <span className="text-[10px] tracking-[0.15em] font-body text-muted-foreground uppercase">({entries.length})</span>
            </div>
            <p className="text-xs font-body text-muted-foreground mt-1">{empty}</p>
          </div>
          {entries.length > 0 && (
            <button
              type="button"
              onClick={() => clearCuration(bucket)}
              className="text-[10px] tracking-[0.15em] font-body text-muted-foreground underline underline-offset-4 hover:text-destructive"
            >
              {lang === "el" ? "Καθαρισμός" : "Clear"}
            </button>
          )}
        </div>
        {entries.length > 0 ? (
          <div className="grid grid-cols-1 gap-3">
            {entries.map(entry => renderCuratedEntry(entry, bucket))}
          </div>
        ) : (
          <p className="border border-dashed border-border p-5 text-center text-[10px] tracking-[0.12em] font-body text-muted-foreground uppercase">
            {lang === "el" ? "Δεν έχει προστεθεί υλικό ακόμη." : "No material added yet."}
          </p>
        )}
      </div>
    );
  };

  const onDrop = (e: React.DragEvent) => { e.preventDefault(); handleFiles(e.dataTransfer.files); };
  const onDragOver = (e: React.DragEvent) => e.preventDefault();

  const displayedLessons = useMemo(() => new URLSearchParams(window.location.search).has("dataUrl")
    ? remoteLessons : [...remoteLessons, ...lessons], [remoteLessons, lessons]);
  const totalCount = useMemo(
    () => displayedLessons.reduce((s, l) => s + l.media.audio.length + l.media.slides.length + l.media.pdf.length + l.media.text.length, 0),
    [displayedLessons]
  );

  // ---------- Puzzles state ----------
  const [puzzles, setPuzzles] = useState<PuzzleScenario[]>(() => {
    try {
      const raw = localStorage.getItem(PUZZLES_KEY);
      if (raw) return JSON.parse(raw);
    } catch {}
    return [];
  });
  const [remotePuzzles, setRemotePuzzles] = useState<PuzzleScenario[]>([]);
  const [playing, setPlaying] = useState<PuzzleScenario | null>(null);
  const puzzleFileRef = useRef<HTMLInputElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);

  useEffect(() => { localStorage.setItem(PUZZLES_KEY, JSON.stringify(puzzles.filter(p => !p.remote))); }, [puzzles]);

  // Load permanent puzzles bundled in public/data/puzzles
  useEffect(() => {
    (async () => {
      try {
        const res = await fetch(`${PUBLIC_BASE_URL}data/puzzles/index.json`, { cache: "no-cache" });
        if (!res.ok) return;
        const files: string[] = await res.json();
        const out: PuzzleScenario[] = [];
        for (const f of files) {
          try {
            const r = await fetch(`${PUBLIC_BASE_URL}data/puzzles/${f}`, { cache: "no-cache" });
            if (!r.ok) continue;
            const data = await r.json();
            if (!data.characters || !data.artifacts) continue;
            const pairs = Math.min(
              (data.characters || []).filter((c: any) => c?.name).length,
              (data.artifacts || []).filter((a: any) => a?.name).length,
            );
            out.push({
              id: `remote_puzzle_${f}`,
              title: data.title || f.replace(/\.json$/i, ""),
              pairs,
              scenario: data,
              addedAt: 0,
              remote: true,
            });
          } catch (e) { console.warn("Failed to load puzzle", f, e); }
        }
        setRemotePuzzles(out);
      } catch (e) { /* no manifest, ignore */ }
    })();
  }, []);

  // Send scenario to iframe when ready
  useEffect(() => {
    if (!playing) return;
    const onMsg = (ev: MessageEvent) => {
      if (ev.data?.type === "puzzle:ready" && playing.scenario && iframeRef.current?.contentWindow) {
        iframeRef.current.contentWindow.postMessage({ type: "puzzle:load", scenario: playing.scenario }, "*");
      }
    };
    window.addEventListener("message", onMsg);
    return () => window.removeEventListener("message", onMsg);
  }, [playing]);

  async function handlePuzzleFiles(files: FileList | null) {
    if (!files?.length) return;
    setStatus({ type: "info", msg: lang === "el" ? "Φόρτωση..." : "Loading..." });
    try {
      let added = 0;
      const next: PuzzleScenario[] = [...puzzles];
      for (const file of Array.from(files)) {
        const text = await file.text();
        const data = JSON.parse(text);
        if (!data.characters || !data.artifacts) {
          throw new Error(lang === "el"
            ? `Μη έγκυρο σενάριο puzzle (${file.name}): λείπουν characters/artifacts.`
            : `Invalid puzzle scenario (${file.name}): missing characters/artifacts.`);
        }
        const pairs = Math.min(
          (data.characters || []).filter((c: any) => c?.name).length,
          (data.artifacts || []).filter((a: any) => a?.name).length,
        );
        next.push({
          id: `puzzle_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
          title: data.title || file.name.replace(/\.json$/i, ""),
          pairs,
          scenario: data,
          addedAt: Date.now(),
        });
        added++;
      }
      setPuzzles(next);
      setStatus({ type: "ok", msg: lang === "el" ? `Εισήχθησαν ${added} puzzle.` : `Imported ${added} puzzles.` });
    } catch (e: any) {
      setStatus({ type: "err", msg: (lang === "el" ? "Σφάλμα: " : "Error: ") + e.message });
    }
    setTimeout(() => setStatus(null), 4000);
    if (puzzleFileRef.current) puzzleFileRef.current.value = "";
  }

  function removePuzzle(id: string) {
    if (!confirm(lang === "el" ? "Διαγραφή puzzle;" : "Remove this puzzle?")) return;
    setPuzzles(prev => prev.filter(p => p.id !== id));
  }

  function exportPuzzleJson(p: PuzzleScenario) {
    if (!p.scenario) return;
    const blob = new Blob([JSON.stringify(p.scenario, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = `${p.title.replace(/\s+/g, "_")}.json`; a.click();
    URL.revokeObjectURL(url);
  }

  const onPuzzleDrop = (e: React.DragEvent) => { e.preventDefault(); handlePuzzleFiles(e.dataTransfer.files); };

  const allPuzzles = useMemo(() => [DEFAULT_PUZZLE, ...remotePuzzles, ...puzzles], [remotePuzzles, puzzles]);


  return (
    <div className="min-h-screen bg-background text-foreground">
      <Navbar />
      <div className="pt-16">
        <section className="p-8 md:p-16 lg:p-24 max-w-6xl mx-auto">
          <span className="text-xs tracking-[0.2em] font-body text-muted-foreground mb-4 block">
            {tr("media.label")}
          </span>
          <h1 className="font-serif text-4xl md:text-5xl italic font-light mb-4">
            {tr("media.title")}
          </h1>
          <p className="font-body text-sm font-light text-muted-foreground max-w-2xl mb-12">
            {tr("media.desc")}
          </p>

          {/* Import zone */}
          <div
            onDrop={onDrop}
            onDragOver={onDragOver}
            onClick={() => fileRef.current?.click()}
            className="border border-dashed border-border bg-card/40 p-10 mb-6 cursor-pointer hover:bg-card transition-colors text-center"
          >
            <Upload className="w-6 h-6 mx-auto mb-3 opacity-60" />
            <p className="font-serif text-lg italic mb-1">{tr("media.drop")}</p>
            <p className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
              {tr("media.hint")}
            </p>
            <input
              ref={fileRef}
              type="file"
              accept=".json,application/json"
              multiple
              className="hidden"
              onChange={(e) => handleFiles(e.target.files)}
            />
          </div>

          <div className="flex flex-wrap items-center gap-4 mb-10">
            <button
              onClick={() => fileRef.current?.click()}
              className="text-xs tracking-[0.2em] font-body border border-foreground px-4 py-2 hover:bg-foreground hover:text-background transition-colors"
            >
              {tr("media.importBtn")}
            </button>
            <button
              onClick={() => curationFileRef.current?.click()}
              className="inline-flex items-center gap-2 text-xs tracking-[0.2em] font-body border border-border px-4 py-2 hover:bg-card transition-colors"
            >
              <Upload className="w-3 h-3" /> {lang === "el" ? "Εισαγωγή επιλογών" : "Import choices"}
            </button>
            <button
              onClick={exportCurations}
              className="inline-flex items-center gap-2 text-xs tracking-[0.2em] font-body border border-border px-4 py-2 hover:bg-card transition-colors"
            >
              <Download className="w-3 h-3" /> {lang === "el" ? "Εξαγωγή επιλογών" : "Export choices"}
            </button>
            <input
              ref={curationFileRef}
              type="file"
              accept=".json,application/json"
              className="hidden"
              onChange={(e) => handleCurationFile(e.target.files)}
            />
            {displayedLessons.length > 0 && (
              <>
                {lessons.length > 0 && (
                  <>
                    <button
                      onClick={exportJson}
                      className="text-xs tracking-[0.2em] font-body border border-border px-4 py-2 hover:bg-card transition-colors inline-flex items-center gap-2"
                    >
                      <Download className="w-3 h-3" /> {tr("media.export")}
                    </button>
                    <button
                      onClick={clearAll}
                      className="text-xs tracking-[0.2em] font-body text-muted-foreground underline underline-offset-4 hover:opacity-60"
                    >
                      {tr("media.clear")}
                    </button>
                  </>
                )}
                <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground ml-auto uppercase">
                  {displayedLessons.length} {tr("media.lessons")} · {totalCount} {tr("media.items")}
                </span>
              </>
            )}
          </div>

          {status && (
            <div className={`mb-8 px-4 py-3 text-xs tracking-[0.15em] font-body uppercase border ${
              status.type === "ok" ? "border-foreground bg-card"
              : status.type === "err" ? "border-destructive text-destructive"
              : "border-border bg-card text-muted-foreground"
            }`}>
              {status.msg}
            </div>
          )}

          {/* Independent curation, kept outside repository-fed lesson data */}
          <section className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-12">
            {renderCurationBucket("current")}
            {renderCurationBucket("selected")}
          </section>

          {/* Lessons */}
          {displayedLessons.length === 0 ? (
            <div className="border border-border bg-card/30 py-20 text-center">
              <p className="font-serif text-xl italic text-muted-foreground mb-2">
                {tr("media.empty")}
              </p>
              <p className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
                {tr("media.emptyHint")}
              </p>
            </div>
          ) : (
            <div className="space-y-6">
              {displayedLessons.map((lesson) => {
                const isOpen = expanded[lesson.id] ?? false;
                const tab = activeTab[lesson.id] ?? firstTab(lesson);
                const tabs = ([
                  { key: "audio" as TabKey, label: tr("media.tab.audio"), icon: Headphones, count: lesson.media.audio.length },
                  { key: "slides" as TabKey, label: tr("media.tab.slides"), icon: Presentation, count: lesson.media.slides.length },
                  { key: "pdf" as TabKey, label: tr("media.tab.pdf"), icon: FileType, count: lesson.media.pdf.length },
                  { key: "text" as TabKey, label: tr("media.tab.text"), icon: FileText, count: lesson.media.text.length },
                ]).filter(t => t.count > 0);

                return (
                  <div key={lesson.id} className="border border-border bg-card/40">
                    <div
                      className={`flex items-start gap-4 p-6 cursor-pointer ${isOpen ? "border-b border-border" : ""}`}
                      onClick={() => setExpanded(p => ({ ...p, [lesson.id]: !isOpen }))}
                    >
                      <div
                        className="w-12 h-12 flex items-center justify-center shrink-0 text-background font-serif italic text-xl"
                        style={{ background: "hsl(var(--foreground))", color: lesson.accent }}
                      >
                        ◆
                      </div>
                      <div className="flex-1 min-w-0">
                        {lesson.remote && (
                          <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
                            {lang === "el" ? "Ενσωματωμένο" : "Bundled"}
                          </span>
                        )}
                        <h3 className="font-serif text-xl md:text-2xl italic font-light mb-1">{lesson.title}</h3>
                        <p className="font-body text-sm text-muted-foreground line-clamp-2">{lesson.description}</p>
                        <div className="flex flex-wrap gap-3 mt-2 text-[10px] tracking-[0.15em] font-body text-muted-foreground uppercase">
                          {lesson.media.audio.length > 0 && <span>{lesson.media.audio.length} {tr("media.tab.audio")}</span>}
                          {lesson.media.slides.length > 0 && <span>{lesson.media.slides.length} {tr("media.tab.slides")}</span>}
                          {lesson.media.pdf.length > 0 && <span>{lesson.media.pdf.length} PDF</span>}
                          {lesson.media.text.length > 0 && <span>{lesson.media.text.length} {tr("media.tab.text")}</span>}
                        </div>
                      </div>
                      {!lesson.remote && (
                        <button
                          onClick={(e) => { e.stopPropagation(); removeLesson(lesson.id); }}
                          className="p-2 text-muted-foreground hover:text-destructive transition-colors"
                          aria-label="Remove"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                      <ChevronDown className={`w-5 h-5 transition-transform ${isOpen ? "rotate-180" : ""}`} />
                    </div>

                    {isOpen && (
                      <div className="p-6">
                        <div className="flex flex-wrap gap-1 mb-6 border-b border-border">
                          {tabs.map(t => {
                            const Icon = t.icon;
                            const active = t.key === tab;
                            return (
                              <button
                                key={t.key}
                                onClick={() => setActiveTab(p => ({ ...p, [lesson.id]: t.key }))}
                                className={`inline-flex items-center gap-2 px-4 py-2 text-[10px] tracking-[0.2em] font-body uppercase border-b-2 transition-colors -mb-px ${
                                  active ? "border-foreground" : "border-transparent text-muted-foreground hover:text-foreground"
                                }`}
                              >
                                <Icon className="w-3 h-3" />
                                {t.label} <span className="opacity-60">({t.count})</span>
                              </button>
                            );
                          })}
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                          {tab === "audio" && lesson.media.audio.map((it, i) => (
                            <article key={i} className="border border-border bg-background p-5">
                              <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
                                {it.isNLM ? "NotebookLM AI" : "Audio"}
                              </span>
                              <h4 className="font-serif text-lg italic mt-1 mb-2">{it.title}</h4>
                              {renderCurationActions(lesson, "audio", i, it)}
                              {it.subtitle && <p className="text-[10px] tracking-[0.15em] font-body uppercase text-muted-foreground mb-2">{it.subtitle}</p>}
                              {it.description && <p className="font-body text-sm text-muted-foreground mb-3">{it.description}</p>}
                              {it.audioUrl && <audio controls className="w-full" src={it.audioUrl} />}
                              {it.isNLM && it.nlmUrl && (
                                <a href={it.nlmUrl} target="_blank" rel="noreferrer"
                                  className="inline-flex items-center gap-2 mt-3 text-xs tracking-[0.2em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors">
                                  {tr("media.open")} <ExternalLink className="w-3 h-3" />
                                </a>
                              )}
                            </article>
                          ))}
                          {tab === "slides" && lesson.media.slides.map((it, i) => (
                            <article key={i} className="border border-border bg-background p-5">
                              <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">Slides</span>
                              <h4 className="font-serif text-lg italic mt-1 mb-2">{it.title}</h4>
                              {renderCurationActions(lesson, "slides", i, it)}
                              {it.description && <p className="font-body text-sm text-muted-foreground mb-3">{it.description}</p>}
                              {it.embedUrl && (
                                <div className="aspect-video mb-3">
                                  <iframe src={it.embedUrl} className="w-full h-full border border-border" title={it.title} />
                                </div>
                              )}
                              {it.directUrl && (
                                <a href={it.directUrl} target="_blank" rel="noreferrer"
                                  className="inline-flex items-center gap-2 text-xs tracking-[0.2em] font-body hover:opacity-60">
                                  {tr("media.open")} <ExternalLink className="w-3 h-3" />
                                </a>
                              )}
                            </article>
                          ))}
                          {tab === "pdf" && lesson.media.pdf.map((it, i) => (
                            <article key={i} className="border border-border bg-background p-5">
                              <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">PDF</span>
                              <h4 className="font-serif text-lg italic mt-1 mb-2">{it.title}</h4>
                              {renderCurationActions(lesson, "pdf", i, it)}
                              {it.description && <p className="font-body text-sm text-muted-foreground mb-3">{it.description}</p>}
                              {it.viewerUrl && (
                                <div className="aspect-[4/3] mb-3">
                                  <iframe src={it.viewerUrl} className="w-full h-full border border-border" title={it.title} />
                                </div>
                              )}
                              {it.pdfUrl && (
                                <div className="flex gap-3">
                                  <a href={it.pdfUrl} target="_blank" rel="noreferrer"
                                    className="text-xs tracking-[0.2em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors">
                                    {tr("media.open")}
                                  </a>
                                  <a href={it.pdfUrl} download
                                    className="text-xs tracking-[0.2em] font-body border border-border px-3 py-2 hover:bg-card transition-colors">
                                    {tr("media.download")}
                                  </a>
                                </div>
                              )}
                            </article>
                          ))}
                          {tab === "text" && lesson.media.text.map((it, i) => (
                            <article key={i} className="border border-border bg-background p-5 flex flex-col">
                              <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">{it.type || "Text"}</span>
                              <h4 className="font-serif text-lg italic mt-1 mb-2">{it.title}</h4>
                              {renderCurationActions(lesson, "text", i, it)}
                              {it.description && <p className="font-body text-sm text-muted-foreground mb-3">{it.description}</p>}
                              <button
                                onClick={() => setModal({ title: it.title, html: it.content })}
                                className="mt-auto text-xs tracking-[0.2em] font-body border border-foreground px-3 py-2 hover:bg-foreground hover:text-background transition-colors self-start"
                              >
                                {tr("media.read")}
                              </button>
                            </article>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </section>

        {/* ──────────── PUZZLES SECTION ──────────── */}
        <section className="p-8 md:p-16 lg:p-24 max-w-6xl mx-auto border-t border-border">
          <div className="flex items-center gap-3 mb-4">
            <Puzzle className="w-4 h-4 opacity-60" />
            <span className="text-xs tracking-[0.2em] font-body text-muted-foreground">
              {tr("media.section.puzzles").toUpperCase()}
            </span>
          </div>
          <h2 className="font-serif text-4xl md:text-5xl italic font-light mb-4">
            {lang === "el" ? "Διαδραστικά Puzzle" : "Interactive Puzzles"}
          </h2>
          <p className="font-body text-sm font-light text-muted-foreground max-w-2xl mb-12">
            {tr("media.puzzles.desc")}
          </p>

          {/* Puzzle import zone */}
          <div
            onDrop={onPuzzleDrop}
            onDragOver={onDragOver}
            onClick={() => puzzleFileRef.current?.click()}
            className="border border-dashed border-border bg-card/40 p-10 mb-6 cursor-pointer hover:bg-card transition-colors text-center"
          >
            <Upload className="w-6 h-6 mx-auto mb-3 opacity-60" />
            <p className="font-serif text-lg italic mb-1">{tr("media.puzzles.drop")}</p>
            <p className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
              {tr("media.hint")}
            </p>
            <input
              ref={puzzleFileRef}
              type="file"
              accept=".json,application/json"
              multiple
              className="hidden"
              onChange={(e) => handlePuzzleFiles(e.target.files)}
            />
          </div>

          <div className="flex flex-wrap items-center gap-4 mb-10">
            <button
              onClick={() => puzzleFileRef.current?.click()}
              className="text-xs tracking-[0.2em] font-body border border-foreground px-4 py-2 hover:bg-foreground hover:text-background transition-colors"
            >
              {tr("media.importBtn")}
            </button>
            <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground ml-auto uppercase">
              {allPuzzles.length} {tr("media.puzzles.count")}
            </span>
          </div>

          {/* Puzzles grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {allPuzzles.map((p, idx) => {
              const accent = ACCENTS[idx % ACCENTS.length];
              const displayTitle = p.builtin
                ? (lang === "el" ? "Αρχαία Αγορά Αθηνών" : "Ancient Agora of Athens")
                : p.title;
              return (
                <article key={p.id} className="border border-border bg-card/40 p-6 flex flex-col">
                  <div className="flex items-start gap-4 mb-4">
                    <div
                      className="w-12 h-12 flex items-center justify-center shrink-0 font-serif italic text-xl"
                      style={{ background: "hsl(var(--foreground))", color: accent }}
                    >
                      ◆
                    </div>
                    <div className="flex-1 min-w-0">
                      <span className="text-[10px] tracking-[0.2em] font-body text-muted-foreground uppercase">
                        {p.builtin ? (lang === "el" ? "Ενσωματωμένο" : "Built-in")
                          : p.remote ? (lang === "el" ? "Ενσωματωμένο" : "Bundled")
                          : "Custom"}
                      </span>
                      <h3 className="font-serif text-xl md:text-2xl italic font-light mt-1">{displayTitle}</h3>
                      <p className="text-[10px] tracking-[0.15em] font-body uppercase text-muted-foreground mt-1">
                        {p.pairs} {tr("media.puzzles.pairs")}
                      </p>
                    </div>
                    {!p.builtin && !p.remote && (
                      <button
                        onClick={() => removePuzzle(p.id)}
                        className="p-2 text-muted-foreground hover:text-destructive transition-colors"
                        aria-label="Remove"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                  <div className="flex flex-wrap gap-3 mt-auto pt-2">
                    <button
                      onClick={() => setPlaying(p)}
                      className="inline-flex items-center gap-2 text-xs tracking-[0.2em] font-body border border-foreground px-4 py-2 hover:bg-foreground hover:text-background transition-colors"
                    >
                      <Play className="w-3 h-3" /> {tr("media.puzzles.play")}
                    </button>
                    {!p.builtin && p.scenario && (
                      <button
                        onClick={() => exportPuzzleJson(p)}
                        className="inline-flex items-center gap-2 text-xs tracking-[0.2em] font-body border border-border px-4 py-2 hover:bg-card transition-colors"
                      >
                        <Download className="w-3 h-3" /> {tr("media.export")}
                      </button>
                    )}
                  </div>
                </article>
              );
            })}
          </div>
        </section>
      </div>

      {/* Play modal */}
      {playing && (
        <div className="fixed inset-0 z-[95] flex items-center justify-center p-2 md:p-6">
          <div className="absolute inset-0 bg-foreground/80" onClick={() => setPlaying(null)} />
          <div className="relative bg-background border border-border w-full h-full max-w-7xl max-h-[95vh] overflow-hidden flex flex-col">
            <div className="flex items-center justify-between p-4 border-b border-border shrink-0">
              <h3 className="font-serif text-lg italic">
                {playing.builtin
                  ? (lang === "el" ? "Αρχαία Αγορά Αθηνών" : "Ancient Agora of Athens")
                  : playing.title}
              </h3>
              <button onClick={() => setPlaying(null)} aria-label="Close"><X className="w-5 h-5" /></button>
            </div>
            <iframe
              ref={iframeRef}
              src={`${PUBLIC_BASE_URL}puzzles/glb-matcher.html`}
              className="flex-1 w-full border-0"
              title="Puzzle"
              allow="xr-spatial-tracking; fullscreen"
            />
          </div>
        </div>
      )}


      {modal && (
        <div className="fixed inset-0 z-[90] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-foreground/60" onClick={() => setModal(null)} />
          <div className="relative bg-background border border-border max-w-3xl w-full max-h-[85vh] overflow-hidden flex flex-col">
            <div className="flex items-center justify-between p-6 border-b border-border">
              <h3 className="font-serif text-xl italic">{modal.title}</h3>
              <button onClick={() => setModal(null)}><X className="w-5 h-5" /></button>
            </div>
            <div
              className="p-6 overflow-y-auto font-body text-sm prose prose-sm max-w-none"
              dangerouslySetInnerHTML={{ __html: modal.html }}
            />
          </div>
        </div>
      )}

      <Footer />
      <SettingsPanel />
    </div>
  );
};

export default Media;
