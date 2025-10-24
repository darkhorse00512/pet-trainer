-- Add English language fields to training_steps table
ALTER TABLE public.training_steps 
ADD COLUMN title_en TEXT,
ADD COLUMN description_en TEXT;

-- Add comments for documentation
COMMENT ON COLUMN public.training_steps.title_en IS 'English title for the training step';
COMMENT ON COLUMN public.training_steps.description_en IS 'English description for the training step';

-- Create index for better performance when querying by language
CREATE INDEX idx_training_steps_language_fields ON public.training_steps (title_en, description_en); 