"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Plus, X } from "lucide-react";
import { createCourse, createModule, createLesson, createExercise, type ActionResult } from "@/lib/actions/content";
import { MVP_EXERCISE_TYPES } from "@/lib/constants";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

// Shared submit wrapper: runs the action, shows the first error, resets on success.
function useFormAction() {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  function run(form: HTMLFormElement, action: (fd: FormData) => Promise<ActionResult>) {
    const fd = new FormData(form);
    start(async () => {
      const r = await action(fd);
      if (r.ok) { form.reset(); setError(null); } else { setError(r.error); }
    });
  }
  return { pending, error, run };
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1.5">
      <Label>{label}</Label>
      {children}
    </div>
  );
}

const selectClass =
  "flex h-10 w-full rounded-md border border-neutral-300 dark:border-neutral-700 bg-transparent px-3 text-sm";

export function CreateCourseForm() {
  const { pending, error, run } = useFormAction();
  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    run(e.currentTarget, createCourse);
  }
  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-2">
          <Field label="Slug"><Input name="slug" placeholder="emergency-medicine-english" required /></Field>
          <Field label="Title"><Input name="title" placeholder="Emergency Medicine English" required /></Field>
          <Field label="Short description"><Input name="short_desc" placeholder="One-liner for cards" /></Field>
          <Field label="Difficulty">
            <select name="difficulty" className={selectClass} defaultValue="beginner">
              <option value="beginner">beginner</option>
              <option value="intermediate">intermediate</option>
              <option value="advanced">advanced</option>
              <option value="mixed">mixed</option>
            </select>
          </Field>
          <div className="sm:col-span-2 flex items-center gap-3">
            <Button type="submit" disabled={pending}>{pending ? "Creating…" : "Add course"}</Button>
            {error && <span className="text-sm text-red-500">{error}</span>}
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

export function CreateModuleForm({ courseId }: { courseId: string }) {
  const { pending, error, run } = useFormAction();
  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    run(e.currentTarget, createModule);
  }
  return (
    <Card><CardContent className="pt-6">
      <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-3">
        <input type="hidden" name="course_id" value={courseId} />
        <Field label="Slug"><Input name="slug" placeholder="patient-intake" required /></Field>
        <Field label="Title"><Input name="title" placeholder="Patient Intake" required /></Field>
        <Field label="Sort order"><Input name="sort_order" type="number" defaultValue={0} /></Field>
        <div className="sm:col-span-3 flex items-center gap-3">
          <Button type="submit" disabled={pending}>{pending ? "Creating…" : "Add module"}</Button>
          {error && <span className="text-sm text-red-500">{error}</span>}
        </div>
      </form>
    </CardContent></Card>
  );
}

export function CreateLessonForm({ moduleId, courseId }: { moduleId: string; courseId: string }) {
  const { pending, error, run } = useFormAction();
  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    run(e.currentTarget, (fd) => createLesson(courseId, fd));
  }
  return (
    <Card><CardContent className="pt-6">
      <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-3">
        <input type="hidden" name="module_id" value={moduleId} />
        <Field label="Slug"><Input name="slug" placeholder="greetings" required /></Field>
        <Field label="Title"><Input name="title" placeholder="Greeting the Patient" required /></Field>
        <Field label="Type">
          <select name="lesson_type" className={selectClass} defaultValue="standard">
            {["standard", "review", "clinical_case", "listening", "pronunciation", "writing", "conversation", "test"].map((t) => (
              <option key={t} value={t}>{t}</option>
            ))}
          </select>
        </Field>
        <Field label="XP reward"><Input name="xp_reward" type="number" defaultValue={50} /></Field>
        <Field label="Sort order"><Input name="sort_order" type="number" defaultValue={0} /></Field>
        <div className="sm:col-span-3 flex items-center gap-3">
          <Button type="submit" disabled={pending}>{pending ? "Creating…" : "Add lesson"}</Button>
          {error && <span className="text-sm text-red-500">{error}</span>}
        </div>
      </form>
    </CardContent></Card>
  );
}

export function CreateExerciseForm({ lessonId, basePath }: { lessonId: string; basePath: string }) {
  const { pending, error, run } = useFormAction();
  const [optionCount, setOptionCount] = useState(4);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    run(e.currentTarget, (fd) => createExercise(basePath, fd));
  }
  return (
    <Card><CardContent className="pt-6">
      <form onSubmit={onSubmit} className="grid gap-4">
        <input type="hidden" name="lesson_id" value={lessonId} />
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Type">
            <select name="exercise_type" className={selectClass} defaultValue="multiple_choice">
              {MVP_EXERCISE_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </Field>
          <Field label="XP reward"><Input name="xp_reward" type="number" defaultValue={10} /></Field>
        </div>
        <Field label="Prompt"><Input name="prompt" placeholder="What does 'dyspnea' mean?" required /></Field>
        <Field label="Correct answer (simple types)"><Input name="correct_answer" placeholder="Difficulty breathing" /></Field>
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Explanation (EN)"><Input name="explanation" /></Field>
          <Field label="Explanation (ES)"><Input name="explanation_es" /></Field>
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <Label>Options (check the correct one[s])</Label>
            <div className="flex gap-1">
              <Button type="button" variant="ghost" size="sm" onClick={() => setOptionCount((c) => c + 1)} aria-label="Add option"><Plus className="h-4 w-4" /></Button>
              <Button type="button" variant="ghost" size="sm" onClick={() => setOptionCount((c) => Math.max(0, c - 1))} aria-label="Remove option"><X className="h-4 w-4" /></Button>
            </div>
          </div>
          {Array.from({ length: optionCount }).map((_, i) => (
            <div key={i} className="flex items-center gap-2">
              <input type="checkbox" name="option_correct" value={i} className="h-4 w-4" aria-label={`Option ${i + 1} correct`} />
              <Input name="option_text" placeholder={`Option ${i + 1}`} />
            </div>
          ))}
        </div>

        <div className="flex items-center gap-3">
          <Button type="submit" disabled={pending}>{pending ? "Creating…" : "Add exercise"}</Button>
          {error && <span className="text-sm text-red-500">{error}</span>}
        </div>
      </form>
    </CardContent></Card>
  );
}
