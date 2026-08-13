
import { createClient } from "@supabase/supabase-js";
import "./style.css";

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

const app = document.querySelector("#app");

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  app.innerHTML = `<div class="auth"><div class="authbox"><h1>Snippet Vault</h1><p>Add your Supabase environment variables first.</p><p><code>VITE_SUPABASE_URL</code><br><code>VITE_SUPABASE_ANON_KEY</code></p></div></div>`;
  throw new Error("Missing Supabase environment variables");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
let user = null;
let snippets = [];
let editingId = null;

const escapeHtml = (s = "") => s.replace(/[&<>"']/g, c => ({ "&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;", "'":"&#039;" }[c]));
const toastEl = () => document.querySelector("#toast");

function toast(text) {
  const el = toastEl();
  if (!el) return;
  clearTimeout(window.__toastTimer);
  el.className = "toast";
  el.textContent = text;
  requestAnimationFrame(() => el.classList.add("show"));
  window.__toastTimer = setTimeout(() => {
    el.classList.remove("show");
    el.classList.add("hide");
    setTimeout(() => el.className = "toast", 220);
  }, 1350);
}

function authView(message = "") {
  app.innerHTML = `
  <div class="auth">
    <div class="authbox">
      <h1>Snippet Vault</h1>
      <p>Keep your reusable messages in the cloud and copy them whenever you need them.</p>
      <input id="email" type="email" autocomplete="email" placeholder="Email">
      <input id="password" type="password" autocomplete="current-password" placeholder="Password">
      <div class="auth-actions">
        <button id="signin" class="primary">Sign in</button>
        <button id="signup" class="secondary">Create account</button>
      </div>
      <p id="auth-note" class="auth-note">${escapeHtml(message)}</p>
    </div>
  </div>`;
  document.querySelector("#signin").onclick = () => handleAuth("signin");
  document.querySelector("#signup").onclick = () => handleAuth("signup");
}

async function handleAuth(mode) {
  const email = document.querySelector("#email").value.trim();
  const password = document.querySelector("#password").value;
  const note = document.querySelector("#auth-note");
  if (!email || !password) { note.textContent = "Enter your email and password."; return; }
  note.textContent = mode === "signin" ? "Signing in…" : "Creating account…";
  const result = mode === "signin"
    ? await supabase.auth.signInWithPassword({ email, password })
    : await supabase.auth.signUp({ email, password });
  if (result.error) { note.textContent = result.error.message; return; }
  if (mode === "signup" && !result.data.session) {
    note.textContent = "Account created. Check your email if confirmation is enabled, then sign in.";
    return;
  }
  user = result.data.user;
  await renderApp();
}

async function loadSnippets() {
  const { data, error } = await supabase
    .from("snippets")
    .select("id,title,content,created_at,updated_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });
  if (error) { toast(error.message); return; }
  snippets = data || [];
}

function mainView() {
  app.innerHTML = `
  <div class="app">
    <div class="top">
      <div><h1>Snippet Vault</h1><div class="sub">Your cloud text library</div></div>
      <div class="user">
        <span class="useremail">${escapeHtml(user.email || "")}</span>
        <button id="signout" class="secondary">Sign out</button>
      </div>
    </div>
    <button id="add" class="primary" style="width:100%;margin-bottom:12px">＋ Add snippet</button>
    <input id="search" class="search" placeholder="Search snippets…">
    <div id="list"></div>
  </div>
  <div id="modal" class="modal">
    <div class="sheet">
      <h2 id="modal-title">Add snippet</h2>
      <input id="title" maxlength="120" placeholder="Title (e.g. TPKS Explanation)">
      <textarea id="content" maxlength="20000" placeholder="Paste your text here…"></textarea>
      <div class="row">
        <button id="cancel" class="secondary">Cancel</button>
        <button id="save" class="primary">Save</button>
      </div>
    </div>
  </div>
  <div id="toast" class="toast"></div>`;

  document.querySelector("#signout").onclick = async () => {
    await supabase.auth.signOut();
  };
  document.querySelector("#add").onclick = () => openEditor();
  document.querySelector("#search").oninput = renderList;
  document.querySelector("#cancel").onclick = closeEditor;
  document.querySelector("#save").onclick = saveSnippet;
  document.querySelector("#modal").addEventListener("click", e => {
    if (e.target.id === "modal") closeEditor();
  });
}

function renderList() {
  const list = document.querySelector("#list");
  if (!list) return;
  const query = document.querySelector("#search").value.toLowerCase();
  const items = snippets.filter(s => `${s.title} ${s.content}`.toLowerCase().includes(query));
  if (!items.length) {
    list.innerHTML = `<div class="empty">${snippets.length ? "No snippets match your search." : "No snippets yet. Tap ＋ Add snippet to create one."}</div>`;
    return;
  }
  list.innerHTML = items.map(s => `
    <div class="card" data-id="${s.id}">
      <div class="cardtop"><div class="title">${escapeHtml(s.title)}</div></div>
      <div class="text">${escapeHtml(s.content)}</div>
      <div class="actions">
        <button class="primary copy">Copy</button>
        <button class="secondary edit">Edit</button>
        <button class="secondary delete">Delete</button>
      </div>
    </div>`).join("");

  list.querySelectorAll(".copy").forEach(btn => btn.onclick = async () => {
    const id = btn.closest(".card").dataset.id;
    const snippet = snippets.find(s => s.id === id);
    btn.classList.remove("pressed"); void btn.offsetWidth; btn.classList.add("pressed");
    try {
      await navigator.clipboard.writeText(snippet.content);
      btn.classList.remove("copied");
      void btn.offsetWidth;
      btn.classList.add("copied");
      btn.textContent = "Copied!";
      clearTimeout(btn.__copyTimer);
      btn.__copyTimer = setTimeout(() => {
        btn.classList.remove("copied");
        btn.textContent = "Copy";
      }, 1000);
    } catch {
      toast("Copy failed — check browser permissions");
    }
  });

  list.querySelectorAll(".edit").forEach(btn => btn.onclick = () => openEditor(btn.closest(".card").dataset.id));
  list.querySelectorAll(".delete").forEach(btn => btn.onclick = () => deleteSnippet(btn.closest(".card").dataset.id));
}

function openEditor(id = null) {
  editingId = id;
  const modal = document.querySelector("#modal");
  const s = id ? snippets.find(x => x.id === id) : null;
  document.querySelector("#modal-title").textContent = s ? "Edit snippet" : "Add snippet";
  document.querySelector("#title").value = s?.title || "";
  document.querySelector("#content").value = s?.content || "";
  modal.classList.add("open");
  setTimeout(() => document.querySelector("#title").focus(), 50);
}

function closeEditor() {
  document.querySelector("#modal")?.classList.remove("open");
  editingId = null;
}

async function showSavedThenClose() {
  const saveBtn = document.querySelector("#save");
  saveBtn.classList.remove("saved");
  void saveBtn.offsetWidth;
  saveBtn.classList.add("saved");
  saveBtn.textContent = "Saved!";
  await new Promise(resolve => setTimeout(resolve, 700));
  saveBtn.classList.remove("saved");
  saveBtn.textContent = "Save";
  closeEditor();
}
async function saveSnippet() {
  const title = document.querySelector("#title").value.trim();
  const content = document.querySelector("#content").value.trim();
  if (!title || !content) { toast("Add a title and text"); return; }

  document.querySelector("#save").disabled = true;

  if (editingId) {
    const { data, error } = await supabase
      .from("snippets")
      .update({ title, content })
      .eq("id", editingId)
      .eq("user_id", user.id)
      .select("id,title,content,created_at,updated_at")
      .single();
    if (error) { toast(error.message); }
    else {
      snippets = snippets.map(s => s.id === editingId ? data : s);
      await showSavedThenClose();
      renderList();
    }
  } else {
    const { data, error } = await supabase
      .from("snippets")
      .insert({ user_id: user.id, title, content })
      .select("id,title,content,created_at,updated_at")
      .single();
    if (error) toast(error.message);
    else {
      snippets.unshift(data);
      await showSavedThenClose();
      renderList();
    }
  }
  document.querySelector("#save").disabled = false;
}

async function deleteSnippet(id) {
  if (!confirm("Delete this snippet?")) return;
  const card = document.querySelector(`.card[data-id="${CSS.escape(id)}"]`);
  card?.classList.add("removing");

  const { error } = await supabase
    .from("snippets")
    .delete()
    .eq("id", id)
    .eq("user_id", user.id);

  if (error) {
    card?.classList.remove("removing");
    toast(error.message);
    return;
  }
  setTimeout(() => {
    snippets = snippets.filter(s => s.id !== id);
    renderList();
    toast("Deleted");
  }, 280);
}

async function renderApp() {
  await loadSnippets();
  mainView();
  renderList();
}

supabase.auth.onAuthStateChange(async (_event, session) => {
  user = session?.user || null;
  if (user) {
    await renderApp();
  } else {
    authView();
  }
});

const { data: { session } } = await supabase.auth.getSession();
user = session?.user || null;
if (user) await renderApp(); else authView();
