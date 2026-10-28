USE cobuy;

SET @db=DATABASE();
SET @sql=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='users' AND COLUMN_NAME='bio')=0,'ALTER TABLE users ADD COLUMN bio VARCHAR(500) NULL AFTER district','SELECT 1'); PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
SET @sql=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='users' AND COLUMN_NAME='avatar')=0,'ALTER TABLE users ADD COLUMN avatar VARCHAR(255) NULL AFTER bio','SELECT 1'); PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
SET @sql=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reports' AND COLUMN_NAME='resolution_note')=0,'ALTER TABLE reports ADD COLUMN resolution_note TEXT NULL AFTER status','SELECT 1'); PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
ALTER TABLE reports MODIFY status ENUM('open','reviewing','resolved','rejected','withdrawn','resolved_positive') NOT NULL DEFAULT 'open';
