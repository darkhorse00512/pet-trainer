-- Add English language fields to training_plans table
ALTER TABLE public.training_plans 
ADD COLUMN title_en TEXT,
ADD COLUMN description_en TEXT;

-- Add comments for documentation
COMMENT ON COLUMN public.training_plans.title_en IS 'English title for the training plan';
COMMENT ON COLUMN public.training_plans.description_en IS 'English description for the training plan';

-- Create index for better performance when querying by language
CREATE INDEX idx_training_plans_language_fields ON public.training_plans (title_en, description_en); 