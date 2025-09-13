-- Function to automatically create user profile when auth.user is created
-- Erstellt am: 13.09.2025

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert new user profile with data from raw_user_meta_data
    INSERT INTO public.user_profiles (
        id,
        first_name,
        last_name,
        username,
        email,
        phone,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'username', ''),
        COALESCE(NEW.email, ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        NOW(),
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically call the function when a new user is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.user_profiles TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.handle_new_user() TO postgres, anon, authenticated, service_role;

-- Test the function (optional - remove in production)
-- This will show how the function works with sample data
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_meta_data JSONB := '{
        "first_name": "Max",
        "last_name": "Mustermann", 
        "username": "maxmuster",
        "phone": "+49123456789"
    }';
BEGIN
    -- Insert test user (this will trigger the function)
    INSERT INTO auth.users (
        id,
        email,
        raw_user_meta_data,
        created_at,
        updated_at
    ) VALUES (
        test_user_id,
        'max.mustermann@example.com',
        test_meta_data,
        NOW(),
        NOW()
    );
    
    -- Check if profile was created
    IF EXISTS (SELECT 1 FROM public.user_profiles WHERE id = test_user_id) THEN
        RAISE NOTICE 'SUCCESS: User profile created automatically for user %', test_user_id;
    ELSE
        RAISE NOTICE 'ERROR: User profile was not created for user %', test_user_id;
    END IF;
    
    -- Clean up test data
    DELETE FROM public.user_profiles WHERE id = test_user_id;
    DELETE FROM auth.users WHERE id = test_user_id;
END $$;
