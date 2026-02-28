-- Backfill adaptive_config for legacy question rows.
-- Keeps existing non-empty configs untouched.

begin;

alter table if exists public.questions
  alter column adaptive_config set default '{}'::jsonb;

-- Normalize nulls to empty object first.
update public.questions
set adaptive_config = '{}'::jsonb
where adaptive_config is null;

-- MCQ and image choice defaults.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('number_sense', 'visual_discrimination'),
  'misconceptionCode', 'choice_option_confusion',
  'misconceptionByOption', '{}'::jsonb,
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'choice'
)
where type in ('mcq', 'imageChoice')
  and adaptive_config = '{}'::jsonb;

-- Fill/text input defaults.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('number_sense', 'basic_operations'),
  'misconceptionCode', 'input_mismatch',
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'default'
)
where type in ('fillInTheBlank', 'textInput')
  and adaptive_config = '{}'::jsonb;

-- Sorting and drag-drop defaults.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('ordering', 'classification'),
  'misconceptionCode', 'ordering_or_grouping_error',
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'manipulative'
)
where type in ('sorting', 'dragAndDrop')
  and adaptive_config = '{}'::jsonb;

-- Measurement defaults.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('measurement_length'),
  'misconceptionCode', 'measurement_scale_error',
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'number'
)
where type = 'measure'
  and adaptive_config = '{}'::jsonb;

-- Four pics one word defaults.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('vocabulary', 'word_building'),
  'misconceptionCode', 'letter_selection_error',
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'letter_tiles'
)
where type = 'fourPicsOneWord'
  and adaptive_config = '{}'::jsonb;

-- Catch-all for any remaining types.
update public.questions
set adaptive_config = jsonb_build_object(
  'conceptTags', jsonb_build_array('general'),
  'misconceptionCode', 'incorrect_default',
  'targetComplexityBand',
    case
      when coalesce(complexity, 0) >= 20 then 'high'
      when coalesce(complexity, 0) >= 10 then 'mid'
      else 'low'
    end,
  'inputMode', 'default'
)
where adaptive_config = '{}'::jsonb;

commit;
