
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { MainLayout } from './components/layout/MainLayout';
import { Dashboard } from './pages/Dashboard';
import { CreateQuestion } from './pages/CreateQuestion';
import { JsonImport } from './pages/JsonImport';

import { ResourceList } from './pages/ResourceList';
import { MicroSkills } from './pages/MicroSkills';
import { MediaGallery } from './pages/MediaGallery';
import { AutoQuestionGenerator } from './pages/AutoQuestionGenerator';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<MainLayout />}>
          <Route index element={<Dashboard />} />
          <Route path="create" element={<CreateQuestion />} />
          <Route path="edit/:id" element={<CreateQuestion />} />
          <Route path="import" element={<JsonImport />} />

          <Route path="grades" element={<ResourceList title="Grades" tableName="grades" columns={['id', 'name', 'sort_order', 'color_hex']} sortBy="sort_order" sortAscending={true} />} />

          <Route path="units" element={<ResourceList title="Units" tableName="units" columns={['id', 'name', 'code', 'sort_order', 'subject_id']} sortBy="sort_order" sortAscending={true} relationships={{ subject_id: 'subjects' }} filterColumn="subject_id" upstreamFilter={{ filterColumn: 'subject_id', parentTable: 'grades', parentColumn: 'grade_id', parentLabel: 'Grade' }} />} />
          <Route path="micro-skills" element={<MicroSkills />} />

          <Route path="subjects" element={<ResourceList title="Subjects" tableName="subjects" columns={['id', 'name', 'slug', 'grade_id']} sortBy="name" sortAscending={true} relationships={{ grade_id: 'grades' }} filterColumn="grade_id" />} />

          <Route path="media" element={<MediaGallery />} />
          <Route path="auto-generator" element={<AutoQuestionGenerator />} />

          <Route path="users" element={<div className="p-10 text-slate-400 font-medium">User Management Placeholder</div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
